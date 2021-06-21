//
//  ToolbarPlacement.swift
//  Grocy Mobile
//
//  Created by Georg Meissner on 21.06.21.
//

import Foundation
import SwiftUI

struct MyToolbarPlacement {
    #if os(iOS)
    static let confirmationAction: ToolbarItemPlacement = .navigationBarTrailing
    #else
    static let confirmationAction: ToolbarItemPlacement = .automatic
    #endif
}
