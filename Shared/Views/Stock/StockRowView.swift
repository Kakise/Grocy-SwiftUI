//
//  StockTableRowSimplified.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 28.12.20.
//

import SwiftUI

struct StockRowView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @AppStorage("expiringDays") var expiringDays: Int = 5
    @AppStorage("localizationKey") var localizationKey: String = "en"
    
    @Environment(\.colorScheme) var colorScheme
#if os(iOS)
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
#endif
    
    var stockElement: StockElement
    @Binding var selectedStockElement: StockElement?
#if os(iOS)
    @Binding var activeSheet: StockInteractionSheet?
#elseif os(macOS)
    @Binding var activeSheet: StockInteractionPopover?
#endif
    @Binding var toastType: RowActionToastType?
    
    @State private var showDetailView: Bool = false
    
    var caloriesSum: String? {
        if let calories = Double(stockElement.product.calories ?? "") {
            let sum = calories * Double(stockElement.amount)!
            return String(format: "%.0f", sum)
        } else { return stockElement.product.calories }
    }
    
    var quantityUnit: MDQuantityUnit {
        grocyVM.mdQuantityUnits.first(where: {$0.id == stockElement.product.quIDStock}) ?? MDQuantityUnit(id: "", name: "Error QU", mdQuantityUnitDescription: nil, rowCreatedTimestamp: "", namePlural: "Error QU", pluralForms: nil, userfields: nil)
    }
    
    var backgroundColor: Color {
        if ((0..<(expiringDays + 1)) ~= getTimeDistanceFromString(stockElement.bestBeforeDate) ?? 100) {
            return colorScheme == .light ? Color.grocyYellowLight : Color.grocyYellowDark
        }
        if (stockElement.dueType == "1" ? (getTimeDistanceFromString(stockElement.bestBeforeDate) ?? 100 < 0) : false) {
            return colorScheme == .light ? Color.grocyGrayLight : Color.grocyGrayDark
        }
        if (stockElement.dueType == "2" ? (getTimeDistanceFromString(stockElement.bestBeforeDate) ?? 100 < 0) : false) {
            return colorScheme == .light ? Color.grocyRedLight : Color.grocyRedDark
        }
        if (Int(stockElement.amount) ?? 1 < Int(stockElement.product.minStockAmount) ?? 0) {
            return colorScheme == .light ? Color.grocyBlueLight : Color.grocyBlueDark
        }
        return Color.clear
    }
    
    var formattedAmountAggregated: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: (Double(stockElement.amountAggregated) ?? 0.0) as NSNumber) ?? "?"
    }
    
    var body: some View {
        content
            .listRowBackground(backgroundColor)
#if os(macOS)
            .sheet(isPresented: $showDetailView, content: {
                ProductOverviewView(productDetails: ProductDetailsModel(product: stockElement.product))
            })
#endif
    }
    
    var content: some View {
        VStack(alignment: .leading){
#if os(iOS)
            if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                HStack{
                    VStack(alignment: .leading){
                        stockElementNameAndActions
                        stockElementDetails
                    }
                    Spacer()
                }
            } else {
                HStack{
                    stockElementNameAndActions
                    stockElementDetails
                    Spacer()
                }
            }
#else
            HStack{
                stockElementNameAndActions
                stockElementDetails
                Spacer()
            }
#endif
        }
    }
    
    var stockElementNameAndActions: some View {
        Text(stockElement.product.name)
            .font(.headline)
            .onTapGesture {
                showDetailView.toggle()
                selectedStockElement = stockElement
                activeSheet = .productOverview
            }
    }
    
    var stockElementDetails: some View {
        VStack(alignment: .leading){
            if let productGroup = grocyVM.mdProductGroups.first(where:{ $0.id == stockElement.product.productGroupID}) {
                Text(productGroup.name)
                    .font(.caption)
            } else {Text("")}
            
            HStack{
                if let formattedAmount = formatStringAmount(stockElement.amount) {
                    Text("\(formattedAmount) \(formattedAmount == "1" ? quantityUnit.name : quantityUnit.namePlural)")
                    if Double(stockElement.amountOpened) ?? 0 > 0 {
                        Text(LocalizedStringKey("str.stock.info.opened \(formatStringAmount(stockElement.amountOpened))"))
                            .font(.caption)
                            .italic()
                    }
                    if let formattedAmountAggregated = formatStringAmount(stockElement.amountAggregated) {
                        if formattedAmount != formattedAmountAggregated {
                            Text("Σ \(formattedAmountAggregated) \(formattedAmountAggregated == "1" ? quantityUnit.name : quantityUnit.namePlural)")
                                .foregroundColor(colorScheme == .light ? Color.grocyGray : Color.grocyGrayLight)
                            if Double(stockElement.amountOpenedAggregated) ?? 0 > 0 {
                                Text(LocalizedStringKey("str.stock.info.opened \(formatStringAmount(stockElement.amountOpenedAggregated))"))
                                    .foregroundColor(colorScheme == .light ? Color.grocyGray : Color.grocyGrayLight)
                                    .font(.caption)
                                    .italic()
                            }
                        }
                    }
                }
                if grocyVM.shoppingList.first(where: {$0.productID == stockElement.productID}) != nil {
                    Image(systemName: MySymbols.shoppingList)
                        .foregroundColor(colorScheme == .light ? Color.grocyGray : Color.grocyGrayLight)
                        .help(LocalizedStringKey("str.stock.info.onShoppingList"))
                }
            }
            if let dueDate = getDateFromString(stockElement.bestBeforeDate) {
                HStack{
                    Text(formatDateAsString(dueDate, showTime: false))
                    Text(getRelativeDateAsText(dueDate, localizationKey: localizationKey))
                        .font(.caption)
                        .italic()
                }
            }
            Divider()
        }
    }
}

struct StockRowView_Previews: PreviewProvider {
    static var previews: some View {
        StockRowView(stockElement: StockElement(amount: "2", amountAggregated: "5", value: "1.0", bestBeforeDate: "12.12.2021", amountOpened: "1", amountOpenedAggregated: "2", isAggregatedAmount: "0", dueType: "1", productID: "1", product: MDProduct(id: "1", name: "Product", mdProductDescription: "", productGroupID: "1", active: "1", locationID: "1", shoppingLocationID: "1", quIDPurchase: "1", quIDStock: "1", quFactorPurchaseToStock: "1", minStockAmount: "0", defaultBestBeforeDays: "0", defaultBestBeforeDaysAfterOpen: "0", defaultBestBeforeDaysAfterFreezing: "0", defaultBestBeforeDaysAfterThawing: "0", pictureFileName: nil, enableTareWeightHandling: "0", tareWeight: "0", notCheckStockFulfillmentForRecipes: "0", parentProductID: nil, calories: "13", cumulateMinStockAmountOfSubProducts: "1", dueType: "1", quickConsumeAmount: "1", rowCreatedTimestamp: "ts", hideOnStockOverview: nil, userfields: nil)), selectedStockElement: Binding.constant(nil), activeSheet: Binding.constant(nil), toastType: Binding.constant(nil))
    }
}
