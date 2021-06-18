//
//  StockTableView.swift
//  Grocy Mobile
//
//  Created by Georg Meissner on 16.06.21.
//

import SwiftUI

struct StockTableView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    var filteredStock: Stock
    
    @AppStorage("localizationKey") var localizationKey: String = "en"
    
    @AppStorage("stockShowProduct") var stockShowProduct: Bool = true
    @AppStorage("stockShowProductGroup") var stockShowProductGroup: Bool = false
    @AppStorage("stockShowAmount") var stockShowAmount: Bool = true
    @AppStorage("stockShowValue") var stockShowValue: Bool = false
    @AppStorage("stockShowNextBestBeforeDate") var stockShowNextBestBeforeDate: Bool = true
    @AppStorage("stockShowCaloriesPerStockQU") var stockShowCaloriesPerStockQU: Bool = false
    @AppStorage("stockShowCalories") var stockShowCalories: Bool = false
    
    //    @State private var sortOrder = [KeyPathComparator(\filteredStock.first!.)]
    
//    @Binding var selectedStockElement: StockElement?
//    @Binding var activeSheet: StockInteractionPopover?
    @Binding var toastType: RowActionToastType?
    
    func caloriesSum(stockElement: StockElement) -> String? {
        if let calories = Double(stockElement.product.calories ?? "") {
            let sum = calories * Double(stockElement.amount)!
            return String(format: "%.0f", sum)
        } else { return stockElement.product.calories }
    }
    
    func quantityUnit(stockElement: StockElement) -> MDQuantityUnit {
        return grocyVM.mdQuantityUnits.first(where: {$0.id == stockElement.product.quIDStock}) ?? MDQuantityUnit(id: "", name: "Error QU", mdQuantityUnitDescription: nil, rowCreatedTimestamp: "", namePlural: "Error QU", pluralForms: nil, userfields: nil)
    }
    
    var body: some View {
        Table(filteredStock, columns: {
            TableColumn(LocalizedStringKey("str.stock.tbl.product"), content: {
                Text(\.product.name)
            })
//            TableColumn(LocalizedStringKey("str.stock.tbl.productGroup"), content: {
//                if let productGroup = grocyVM.mdProductGroups.first(where:{ $0.id == \.product.productGroupID}) {
//                    Text(productGroup.name)
//                } else {
//                    Text("")
//                }
//            })
//            TableColumn(LocalizedStringKey("str.stock.tbl.amount"), content: {
//                if let formattedAmount = formatStringAmount(\.amount) {
//                    Text("\(formattedAmount) \(formattedAmount == "1" ? quantityUnit(\.self).name : quantityUnit(\.self).namePlural)")
//                    if Double(\.amountOpened) ?? 0 > 0 {
//                        Text(LocalizedStringKey("str.stock.info.opened \(formatStringAmount(\.amountOpened))"))
//                            .font(.caption)
//                            .italic()
//                    }
//                    if let formattedAmountAggregated = formatStringAmount(\.amountAggregated) {
//                        if formattedAmount != formattedAmountAggregated {
//                            Text("Σ \(formattedAmountAggregated) \(formattedAmountAggregated == "1" ? quantityUnit.name : quantityUnit.namePlural)")
//                                .foregroundColor(colorScheme == .light ? Color.grocyGray : Color.grocyGrayLight)
//                            if Double(\.amountOpenedAggregated) ?? 0 > 0 {
//                                Text(LocalizedStringKey("str.stock.info.opened \(formatStringAmount(\.amountOpenedAggregated))"))
//                                    .foregroundColor(colorScheme == .light ? Color.grocyGray : Color.grocyGrayLight)
//                                    .font(.caption)
//                                    .italic()
//                            }
//                        }
//                    }
//                }
//                if grocyVM.shoppingList.first(where: {$0.productID == \.productID}) != nil {
//                    Image(systemName: MySymbols.shoppingList)
//                        .foregroundColor(colorScheme == .light ? Color.grocyGray : Color.grocyGrayLight)
//                        .help(LocalizedStringKey("str.stock.info.onShoppingList"))
//                }
//            })
//            TableColumn(LocalizedStringKey("str.stock.tbl.value"), content: {
//                Text(Double(\.value) == 0 ? "" : "\(\.value) \(grocyVM.getCurrencySymbol())")
//            })
//            TableColumn(LocalizedStringKey("str.stock.tbl.nextBestBefore"), content: {
//                if let dueDate = getDateFromString(\.bestBeforeDate) {
//                    Text(formatDateAsString(dueDate, showTime: false))
//                    Text(getRelativeDateAsText(dueDate, localizationKey: localizationKey))
//                        .font(.caption)
//                        .italic()
//                }
//            })
//            TableColumn(LocalizedStringKey("str.stock.tbl.caloriesPerStockQU"), content: {
//                Text(\.product.calories != "0" ? \.product.calories ?? "" : "")
//            })
//            TableColumn(LocalizedStringKey("str.stock.tbl.calories"), content: {
//                Text(((caloriesSum(\.self) == "0") ? "" : caloriesSum(\.self)) ?? "")
//            })
        })
    }
}

//struct StockTableView_Previews: PreviewProvider {
//    static var previews: some View {
//        StockTableView()
//    }
//}
