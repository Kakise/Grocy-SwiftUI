//
//  StockRowView.swift
//  grocy-ios
//
//  Created by Georg Meissner on 29.10.20.
//

import SwiftUI

struct StockTableRow: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @AppStorage("expiringDays") var expiringDays: Int = 5
    @AppStorage("localizationKey") var localizationKey: String = "en"
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showProduct: Bool
    @Binding var showProductGroup: Bool
    @Binding var showAmount: Bool
    @Binding var showValue: Bool
    @Binding var showNextBestBeforeDate: Bool
    @Binding var showCaloriesPerStockQU: Bool
    @Binding var showCalories: Bool
    
    var stockElement: StockElement
    @Binding var selectedStockElement: StockElement?
    #if os(iOS)
    @Binding var activeSheet: StockInteractionSheet?
    #elseif os(macOS)
    @Binding var activeSheet: StockInteractionPopover?
    #endif
    @Binding var toastType: RowActionToastType?
    
    @State private var showDetailView: Bool = false
    
    var quantityUnit: MDQuantityUnit? {
        grocyVM.mdQuantityUnits.first(where: {$0.id == stockElement.product.quIDStock})
    }
    
    private func getQUString(amount: Double) -> String {
        return amount == 1.0 ? quantityUnit?.name ?? "" : quantityUnit?.namePlural ?? ""
    }
    
    var backgroundColor: Color {
        if ((0..<(expiringDays + 1)) ~= getTimeDistanceFromString(stockElement.bestBeforeDate) ?? 100) {
            return colorScheme == .light ? Color.grocyYellowLight : Color.grocyYellowDark
        }
        if (stockElement.dueType == 1 ? (getTimeDistanceFromString(stockElement.bestBeforeDate) ?? 100 < 0) : false) {
            return colorScheme == .light ? Color.grocyGrayLight : Color.grocyGrayDark
        }
        if (stockElement.dueType == 2 ? (getTimeDistanceFromString(stockElement.bestBeforeDate) ?? 100 < 0) : false) {
            return colorScheme == .light ? Color.grocyRedLight : Color.grocyRedDark
        }
        if (stockElement.amount < stockElement.product.minStockAmount) {
            return colorScheme == .light ? Color.grocyBlueLight : Color.grocyBlueDark
        }
        return Color.clear
    }
    
    var body: some View {
        StockTableRowActionsView(stockElement: stockElement, selectedStockElement: $selectedStockElement, activeSheet: $activeSheet, toastType: $toastType)
        
        if showProduct {
            HStack{
                Divider()
                Spacer()
                Text(stockElement.product.name)
                    .onTapGesture {
                        showDetailView.toggle()
                        #if os(iOS)
                        selectedStockElement = stockElement
                        activeSheet = .productOverview
                        #endif
                    }
                Spacer()
            }
            .background(backgroundColor)
            .sheet(isPresented: $showDetailView, content: {
                #if os(macOS)
                ProductOverviewView(productDetails: ProductDetailsModel(product: stockElement.product))
                #endif
            })
        }
        
        if showProductGroup {
            HStack{
                Divider()
                Spacer()
                if let productGroup = grocyVM.mdProductGroups.first(where:{ $0.id == stockElement.product.productGroupID}) {
                    Text(productGroup.name)
                } else {
                    Text("")
                }
                Spacer()
            }
            .background(backgroundColor)
        }
        
        if showAmount {
            VStack(alignment: .center){
                Spacer()
                HStack(alignment: .bottom){
                    Divider()
                    Spacer()
                    Text("\(formatAmount(stockElement.amount)) \(getQUString(amount: stockElement.amount))")
                    if stockElement.amountOpened > 0 {
                        Text(LocalizedStringKey("str.stock.info.opened \(formatAmount(stockElement.amountOpened))"))
                            .font(.caption)
                            .italic()
                    }
                    if stockElement.amount != stockElement.amountAggregated {
                        Text("Σ \(formatAmount(stockElement.amountAggregated)) \(getQUString(amount: stockElement.amountAggregated))")
                            .foregroundColor(colorScheme == .light ? Color.grocyGray : Color.grocyGrayLight)
                        if stockElement.amountOpenedAggregated > 0 {
                            Text(LocalizedStringKey("str.stock.info.opened \(formatAmount(stockElement.amountOpenedAggregated))"))
                                .foregroundColor(colorScheme == .light ? Color.grocyGray : Color.grocyGrayLight)
                                .font(.caption)
                                .italic()
                        }
                    }
                    if grocyVM.shoppingList.first(where: {$0.productID == stockElement.productID}) != nil {
                        Image(systemName: MySymbols.shoppingList)
                            .foregroundColor(colorScheme == .light ? Color.grocyGray : Color.grocyGrayLight)
                            .help(LocalizedStringKey("str.stock.info.onShoppingList"))
                    }
                    Spacer()
                }
                
                Spacer()
            }
            .background(backgroundColor)
        }
        
        if showValue {
            HStack{
                Divider()
                Spacer()
                Text(stockElement.value == 0 ? "" : "\(formatAmount(stockElement.value)) \(grocyVM.getCurrencySymbol())")
                Spacer()
            }
            .background(backgroundColor)
        }
        
        if showNextBestBeforeDate {
            VStack{
                HStack(alignment: .center){
                    Divider()
                    Spacer()
                    if let dueDate = getDateFromString(stockElement.bestBeforeDate) {
                        Text(formatDateAsString(dueDate, showTime: false))
                        Text(getRelativeDateAsText(dueDate, localizationKey: localizationKey))
                            .font(.caption)
                            .italic()
                    }
                    Spacer()
                }
            }
            .background(backgroundColor)
        }
        
        if showCaloriesPerStockQU {
            HStack{
                Divider()
                Spacer()
                Text(stockElement.product.calories != 0.0 ? String(formatAmount(stockElement.product.calories ?? 0)) : "")
                Spacer()
            }
            .background(backgroundColor)
        }
        
        if showCalories {
            HStack {
                Divider()
                Spacer()
                Text(formatAmount(stockElement.product.calories ?? 0 * stockElement.amount))
                Spacer()
            }
            .background(backgroundColor)
        }
    }
}

//struct StockTableRow_Previews: PreviewProvider {
//    static var previews: some View {
//        StockTableRow(expiringDays: 5, showProduct: Binding.constant(true), showProductGroup: Binding.constant(true), showAmount: Binding.constant(true), showValue: Binding.constant(true), showNextBestBeforeDate: Binding.constant(true), showCaloriesPerStockQU: Binding.constant(true), showCalories: Binding.constant(true), stockElement: StockElement(amount: "3", amountAggregated: "3", value: "25", bestBeforeDate: "2020-12-12", amountOpened: "1", amountOpenedAggregated: "1", isAggregatedAmount: "0", dueType: "1", productID: "3", product: MDProduct(id: "3", name: "Productname", mdProductDescription: "Description", productGroupID: "1", active: "1", locationID: "1", shoppingLocationID: "1", quIDPurchase: "1", quIDStock: "1", quFactorPurchaseToStock: "1", minStockAmount: "1", defaultBestBeforeDays: "1", defaultBestBeforeDaysAfterOpen: "1", defaultBestBeforeDaysAfterFreezing: "1", defaultBestBeforeDaysAfterThawing: "1", pictureFileName: nil, enableTareWeightHandling: "0", tareWeight: "1", notCheckStockFulfillmentForRecipes: "1", parentProductID: "1", calories: "1233", cumulateMinStockAmountOfSubProducts: "0", dueType: "1", quickConsumeAmount: "1", rowCreatedTimestamp: "ts", userfields: nil)))
//    }
//}
