//
//  ProductsModel.swift
//  grocy-ios
//
//  Created by Georg Meissner on 13.10.20.
//

import Foundation

// MARK: - MDProduct
struct MDProduct: Codable {
    let id: Int
    let name: String
    @NullCodable var mdProductDescription: String?
    @NullCodable var productGroupID: Int?
    let active, locationID: Int
    @NullCodable var shoppingLocationID: Int?
    let quIDPurchase, quIDStock: Int
    @NullCodable var quFactorPurchaseToStock: Double?
    let minStockAmount: Double
    let defaultBestBeforeDays, defaultBestBeforeDaysAfterOpen, defaultBestBeforeDaysAfterFreezing, defaultBestBeforeDaysAfterThawing: Int
    @NullCodable var pictureFileName: String?
    let enableTareWeightHandling: Int?
    @NullCodable var tareWeight: Double?
    let notCheckStockFulfillmentForRecipes: Int?
    @NullCodable var parentProductID: Int?
    @NullCodable var calories: Double?
    let cumulateMinStockAmountOfSubProducts: Int?
    let dueType: Int
    @NullCodable var quickConsumeAmount: Double?
    @NullCodable var hideOnStockOverview: Int?
    let rowCreatedTimestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case mdProductDescription = "description"
        case productGroupID = "product_group_id"
        case active
        case locationID = "location_id"
        case shoppingLocationID = "shopping_location_id"
        case quIDPurchase = "qu_id_purchase"
        case quIDStock = "qu_id_stock"
        case quFactorPurchaseToStock = "qu_factor_purchase_to_stock"
        case minStockAmount = "min_stock_amount"
        case defaultBestBeforeDays = "default_best_before_days"
        case defaultBestBeforeDaysAfterOpen = "default_best_before_days_after_open"
        case defaultBestBeforeDaysAfterFreezing = "default_best_before_days_after_freezing"
        case defaultBestBeforeDaysAfterThawing = "default_best_before_days_after_thawing"
        case pictureFileName = "picture_file_name"
        case enableTareWeightHandling = "enable_tare_weight_handling"
        case tareWeight = "tare_weight"
        case notCheckStockFulfillmentForRecipes = "not_check_stock_fulfillment_for_recipes"
        case parentProductID = "parent_product_id"
        case calories
        case cumulateMinStockAmountOfSubProducts = "cumulate_min_stock_amount_of_sub_products"
        case dueType = "due_type"
        case quickConsumeAmount = "quick_consume_amount"
        case rowCreatedTimestamp = "row_created_timestamp"
        case hideOnStockOverview = "hide_on_stock_overview"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            do { self.id = try container.decode(Int.self, forKey: .id) } catch { self.id = Int(try container.decode(String.self, forKey: .id))! }
            self.name = try container.decode(String.self, forKey: .name)
            self.mdProductDescription = try? container.decodeIfPresent(String.self, forKey: .mdProductDescription) ?? nil
            do { self.productGroupID = try container.decodeIfPresent(Int.self, forKey: .productGroupID) } catch { self.productGroupID = try Int(container.decodeIfPresent(String.self, forKey: .productGroupID) ?? "") }
            do { self.active = try container.decode(Int.self, forKey: .active) } catch { self.active = try Int(container.decode(String.self, forKey: .active)) ?? 0 }
            do { self.locationID = try container.decode(Int.self, forKey: .locationID) } catch { self.locationID = try Int(container.decode(String.self, forKey: .locationID))! }
            do { self.shoppingLocationID = try container.decodeIfPresent(Int.self, forKey: .shoppingLocationID) } catch { self.shoppingLocationID = try? Int(container.decodeIfPresent(String.self, forKey: .shoppingLocationID) ?? "") }
            do { self.quIDPurchase = try container.decode(Int.self, forKey: .quIDPurchase) } catch { self.quIDPurchase = try Int(container.decode(String.self, forKey: .quIDPurchase))! }
            do { self.quIDStock = try container.decode(Int.self, forKey: .quIDStock) } catch { self.quIDStock = try Int(container.decode(String.self, forKey: .quIDStock))! }
            do { self.quFactorPurchaseToStock = try container.decode(Double.self, forKey: .quFactorPurchaseToStock) } catch { self.quFactorPurchaseToStock = try? Double(container.decodeIfPresent(String.self, forKey: .quFactorPurchaseToStock) ?? "") }
            do { self.minStockAmount = try container.decode(Double.self, forKey: .minStockAmount) } catch { self.minStockAmount = try Double(container.decode(String.self, forKey: .minStockAmount))! }
            do { self.defaultBestBeforeDays = try container.decode(Int.self, forKey: .defaultBestBeforeDays) } catch { self.defaultBestBeforeDays = try Int(container.decode(String.self, forKey: .defaultBestBeforeDays))! }
            do { self.defaultBestBeforeDaysAfterOpen = try container.decode(Int.self, forKey: .defaultBestBeforeDaysAfterOpen) } catch { self.defaultBestBeforeDaysAfterOpen = try Int(container.decode(String.self, forKey: .defaultBestBeforeDaysAfterOpen))! }
            do { self.defaultBestBeforeDaysAfterFreezing = try container.decode(Int.self, forKey: .defaultBestBeforeDaysAfterFreezing) } catch { self.defaultBestBeforeDaysAfterFreezing = try Int(container.decode(String.self, forKey: .defaultBestBeforeDaysAfterFreezing))! }
            do { self.defaultBestBeforeDaysAfterThawing = try container.decode(Int.self, forKey: .defaultBestBeforeDaysAfterThawing) } catch { self.defaultBestBeforeDaysAfterThawing = try Int(container.decode(String.self, forKey: .defaultBestBeforeDaysAfterThawing))! }
            self.pictureFileName = try? container.decodeIfPresent(String.self, forKey: .pictureFileName) ?? nil
            do { self.enableTareWeightHandling = try container.decode(Int.self, forKey: .enableTareWeightHandling) } catch { self.enableTareWeightHandling = try? Int(container.decodeIfPresent(String.self, forKey: .enableTareWeightHandling) ?? "") }
            do { self.tareWeight = try container.decode(Double.self, forKey: .tareWeight) } catch { self.tareWeight = try? Double(container.decodeIfPresent(String.self, forKey: .tareWeight) ?? "") }
            do { self.notCheckStockFulfillmentForRecipes = try container.decode(Int.self, forKey: .notCheckStockFulfillmentForRecipes) } catch { self.notCheckStockFulfillmentForRecipes = try? Int(container.decodeIfPresent(String.self, forKey: .notCheckStockFulfillmentForRecipes) ?? "") }
            do { self.parentProductID = try container.decode(Int.self, forKey: .parentProductID) } catch { self.parentProductID = try? Int(container.decodeIfPresent(String.self, forKey: .parentProductID) ?? "") }
            do { self.calories = try container.decodeIfPresent(Double.self, forKey: .calories) } catch { self.calories = try? Double(container.decodeIfPresent(String.self, forKey: .calories) ?? "") }
            do { self.cumulateMinStockAmountOfSubProducts = try container.decodeIfPresent(Int.self, forKey: .cumulateMinStockAmountOfSubProducts) } catch { self.cumulateMinStockAmountOfSubProducts = try? Int(container.decodeIfPresent(String.self, forKey: .cumulateMinStockAmountOfSubProducts) ?? "") }
            do { self.dueType = try container.decode(Int.self, forKey: .dueType) } catch { self.dueType = try Int(container.decode(String.self, forKey: .dueType))! }
            do { self.quickConsumeAmount = try container.decodeIfPresent(Double.self, forKey: .quickConsumeAmount) } catch { self.quickConsumeAmount = try? Double(container.decodeIfPresent(String.self, forKey: .quickConsumeAmount) ?? "") }
            do { self.hideOnStockOverview = try container.decodeIfPresent(Int.self, forKey: .hideOnStockOverview) } catch { self.hideOnStockOverview = try? Int(container.decodeIfPresent(String.self, forKey: .hideOnStockOverview) ?? "") }
            self.rowCreatedTimestamp = try container.decode(String.self, forKey: .rowCreatedTimestamp)
        } catch {
            throw APIError.decodingError(error: error)
        }
    }
    
    init(id: Int,
         name: String,
         mdProductDescription: String? = nil,
         productGroupID: Int? = nil,
         active: Int,
         locationID: Int,
         shoppingLocationID: Int? = nil,
         quIDPurchase: Int,
         quIDStock: Int,
         quFactorPurchaseToStock: Double? = nil,
         minStockAmount: Double,
         defaultBestBeforeDays: Int,
         defaultBestBeforeDaysAfterOpen: Int,
         defaultBestBeforeDaysAfterFreezing: Int,
         defaultBestBeforeDaysAfterThawing: Int,
         pictureFileName: String? = nil,
         enableTareWeightHandling: Int? = nil,
         tareWeight: Double? = nil,
         notCheckStockFulfillmentForRecipes: Int? = nil,
         parentProductID: Int? = nil,
         calories: Double? = nil,
         cumulateMinStockAmountOfSubProducts: Int,
         dueType: Int,
         quickConsumeAmount: Double? = nil,
         hideOnStockOverview: Int? = nil,
         rowCreatedTimestamp: String) {
        self.id = id
        self.name = name
        self.mdProductDescription = mdProductDescription
        self.productGroupID = productGroupID
        self.active = active
        self.locationID = locationID
        self.shoppingLocationID = shoppingLocationID
        self.quIDPurchase = quIDPurchase
        self.quIDStock = quIDStock
        self.quFactorPurchaseToStock = quFactorPurchaseToStock
        self.minStockAmount = minStockAmount
        self.defaultBestBeforeDays = defaultBestBeforeDays
        self.defaultBestBeforeDaysAfterOpen = defaultBestBeforeDaysAfterOpen
        self.defaultBestBeforeDaysAfterFreezing = defaultBestBeforeDaysAfterFreezing
        self.defaultBestBeforeDaysAfterThawing = defaultBestBeforeDaysAfterThawing
        self.pictureFileName = pictureFileName
        self.enableTareWeightHandling = enableTareWeightHandling
        self.tareWeight = tareWeight
        self.notCheckStockFulfillmentForRecipes = notCheckStockFulfillmentForRecipes
        self.parentProductID = parentProductID
        self.calories = calories
        self.cumulateMinStockAmountOfSubProducts = cumulateMinStockAmountOfSubProducts
        self.dueType = dueType
        self.quickConsumeAmount = quickConsumeAmount
        self.hideOnStockOverview = hideOnStockOverview
        self.rowCreatedTimestamp = rowCreatedTimestamp
    }
}

typealias MDProducts = [MDProduct]
