//
//  StockTableView.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 13.11.20.
//

import SwiftUI

struct StockTable: View {
    var filteredStock: Stock
    
#if os(macOS)
    @AppStorage("simplifiedStockView") var simplifiedStockView: Bool = false
#endif
    
    @Binding var selectedStockElement: StockElement?
#if os(iOS)
    @Binding var activeSheet: StockInteractionSheet?
#elseif os(macOS)
    @Binding var activeSheet: StockInteractionPopover?
#endif
    @Binding var toastType: RowActionToastType?
    
    var body: some View {
#if os(macOS)
        if !simplifiedStockView{
            contentTable
        } else {
            content
        }
#else
        content
#endif
    }
    
    var content: some View {
        ForEach(filteredStock, id:\.productID) { stockElement in
            StockRowView(stockElement: stockElement, selectedStockElement: $selectedStockElement, activeSheet: $activeSheet, toastType: $toastType)
        }
    }
    
    var contentTable: some View {
        Text("NOT IMPLEMENTED")
    }
}

//struct StockTable_Previews: PreviewProvider {
//    static var previews: some View {
//        StockTable(filteredStock: [                            StockElement(amount: "3", amountAggregated: "3", value: "25", bestBeforeDate: "2020-12-12", amountOpened: "1", amountOpenedAggregated: "1", isAggregatedAmount: "0", dueType: "1", productID: "3", product: MDProduct(id: "3", name: "Productname", mdProductDescription: "Description", productGroupID: "1", active: "1", locationID: "1", shoppingLocationID: "1", quIDPurchase: "1", quIDStock: "1", quFactorPurchaseToStock: "1", minStockAmount: "1", defaultBestBeforeDays: "1", defaultBestBeforeDaysAfterOpen: "1", defaultBestBeforeDaysAfterFreezing: "1", defaultBestBeforeDaysAfterThawing: "1", pictureFileName: nil, enableTareWeightHandling: "0", tareWeight: "1", notCheckStockFulfillmentForRecipes: "1", parentProductID: "1", calories: "1233", cumulateMinStockAmountOfSubProducts: "0", dueType: "1", quickConsumeAmount: "1", rowCreatedTimestamp: "ts", userfields: nil))])
//    }
//}
