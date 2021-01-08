//
//  ProductsModel.swift
//  grocy-ios
//
//  Created by Georg Meissner on 13.10.20.
//

import Foundation

// MARK: - MDProduct
struct MDProduct: Codable, Hashable {
    let id, name: String
    let mdProductDescription, productGroupID: String?
    let active, locationID: String
    let shoppingLocationID: String?
    let quIDPurchase, quIDStock, quFactorPurchaseToStock, minStockAmount: String
    let defaultBestBeforeDays, defaultBestBeforeDaysAfterOpen, defaultBestBeforeDaysAfterFreezing, defaultBestBeforeDaysAfterThawing: String
    let pictureFileName: String?
    let enableTareWeightHandling, tareWeight, notCheckStockFulfillmentForRecipes: String
    let parentProductID, calories: String?
    let cumulateMinStockAmountOfSubProducts, dueType, quickConsumeAmount: String
    let rowCreatedTimestamp: String
    let hideOnStockOverview: String?
    let userfields: [String: String]?
    
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
        case userfields
    }
}

typealias MDProducts = [MDProduct]

// MARK: - MDProductPOST
struct MDProductPOST: Codable {
    let id: Int
    let name: String
    let mdProductDescription, productGroupID: String?
    let active, locationID: String
    let shoppingLocationID: String?
    let quIDPurchase, quIDStock: String
    let quFactorPurchaseToStock, minStockAmount: Double?
    let defaultBestBeforeDays, defaultBestBeforeDaysAfterOpen, defaultBestBeforeDaysAfterFreezing, defaultBestBeforeDaysAfterThawing: Int?
    let pictureFileName: String?
    let enableTareWeightHandling: String?
    let tareWeight: Double?
    let notCheckStockFulfillmentForRecipes: String?
    let parentProductID: String?
    let calories: Double?
    let cumulateMinStockAmountOfSubProducts, dueType: String?
    let quickConsumeAmount: Double?
    let rowCreatedTimestamp: String
    let hideOnStockOverview: String?
    let userfields: [String: String]?
    
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
        case userfields
    }
}
