//
//  HomeAssistantAPI.swift
//  Grocy Mobile
//
//  Created by Georg Meissner on 21.08.21.
//

import Foundation
import Combine

// MARK: - HomeAssistantSessionCookie
struct HomeAssistantSessionCookieReturn: Codable {
    let result: String
    let data: HomeAssistantSessionCookie?
    
    enum CodingKeys: String, CodingKey {
        case result, data
    }
    
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.result = try container.decode(String.self, forKey: .result)
            do { self.data = try container.decodeIfPresent(HomeAssistantSessionCookie.self, forKey: .data) } catch { self.data = nil }
        } catch {
            throw APIError.decodingError(error: error)
        }
    }
    
    init(result: String, data: HomeAssistantSessionCookie?) {
        self.result = result
        self.data = data
    }
}

// MARK: - DataClass
struct HomeAssistantSessionCookie: Codable {
    let session: String
}
struct HomeAssistantSessionCookieEmpty: Codable {
}

protocol NetworkSession: AnyObject {
    func publisher(for request: URLRequest) -> AnyPublisher<HomeAssistantSessionCookieReturn, APIError>
}

extension URLSession: NetworkSession {
    func publisher(for request: URLRequest) -> AnyPublisher<HomeAssistantSessionCookieReturn, APIError> {
        return dataTaskPublisher(for: request)
            .tryMap({ result in
                guard let httpResponse = result.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw APIError.unsuccessful
                }
                let cookieReturn = try JSONDecoder().decode(HomeAssistantSessionCookieReturn.self, from: result.data)
                return cookieReturn
            })
            .mapError({ error in APIError.hassError(error: error) })
            .eraseToAnyPublisher()
    }
}

class HomeAssistantAuthenticator {
    private var hassURL: String = ""
    private var hassToken: String? = nil
    
    private var hassIngressToken: String?
    private var hassIngressTokenDate: Date?
    
    private let session: NetworkSession
    private let queue = DispatchQueue(label: "Authenticator.\(UUID().uuidString)")
    
    // this publisher is shared amongst all calls that request a token refresh
    private var refreshPublisher: AnyPublisher<HomeAssistantSessionCookieReturn, APIError>?
    
    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }
    
    init(hassURL: String, hassToken: String, session: NetworkSession = URLSession.shared) {
        self.hassURL = hassURL
        self.hassToken = hassToken
        self.session = session
    }
    
    func getToken() -> String? {
        return hassIngressToken
    }
    
    func validToken(forceRefresh: Bool = false) -> AnyPublisher<HomeAssistantSessionCookieReturn, APIError> {
        return queue.sync { [weak self] in
            // Scenario 1: a new Token is already loading
            if let publisher = self?.refreshPublisher {
                return publisher
            }
            
            // Scenario 2: There is no session Token, create a new one
            if hassIngressToken == nil {
                let publisher = session.publisher(for: request(renewCookie: false))
                    .share()
                    .handleEvents(receiveOutput: { token in
                        self?.hassIngressToken = token.data?.session
                        self?.hassIngressTokenDate = Date()
                    }, receiveCompletion: { _ in
                        self?.queue.sync {
                            self?.refreshPublisher = nil
                        }
                    })
                    .eraseToAnyPublisher()
                self?.refreshPublisher = publisher
                return publisher
            }
            
            // Scenario 3: The session Token is valid and will be returned
            if hassIngressTokenDate?.distance(to: Date()) ?? 100 < 60, !forceRefresh {
                return Just(HomeAssistantSessionCookieReturn(result: "ok", data: HomeAssistantSessionCookie(session: hassIngressToken!)))
                    .setFailureType(to: APIError.self)
                    .eraseToAnyPublisher()
            }
            
            // Scenario 4: The session Token is old, refresh it
            let publisher = session.publisher(for: request(renewCookie: true))
                .share()
                .handleEvents(receiveOutput: { token in
                    self?.hassIngressTokenDate = Date()
                }, receiveCompletion: { _ in
                    self?.queue.sync {
                        self?.hassIngressTokenDate = Date()
                        self?.refreshPublisher = nil
                    }
                })
                .eraseToAnyPublisher()
            
            self?.refreshPublisher = publisher
            return publisher
        }
    }
    
    func request(renewCookie: Bool) -> URLRequest {
        let path = "\(hassURL)/api/hassio/ingress\(renewCookie ? "/validate_session" : "/session")"
        
        guard let url = URL(string: path)
        else {
            preconditionFailure("Bad URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let hassToken = hassToken {
            request.allHTTPHeaderFields = ["Authorization": "Bearer \(hassToken)"]
        } else {
            preconditionFailure("No Access Token")
        }
        
        if renewCookie {
            if let hassIngressToken = hassIngressToken {
                request.httpBody = try! JSONEncoder().encode(HomeAssistantSessionCookie(session: hassIngressToken))
            }
        }
        
        request.timeoutInterval = 3
        return request
    }
}
