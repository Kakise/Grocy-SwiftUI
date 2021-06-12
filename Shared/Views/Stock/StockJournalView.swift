//
//  StockJournalView.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 20.11.20.
//

import SwiftUI

struct StockJournalFilterBar: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @Binding var filteredProductID: String?
    @Binding var filteredTransactionType: TransactionType?
    @Binding var filteredLocationID: String?
    @Binding var filteredUserID: String?
    
#if os(iOS)
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
#endif
    
    var body: some View {
        VStack{
#if os(iOS)
            let filterColumns = [GridItem](repeating: GridItem(.flexible()), count: (horizontalSizeClass == .compact && verticalSizeClass == .regular) ? 2 : 4)
#else
            let filterColumns = [GridItem](repeating: GridItem(.flexible()), count: 4)
#endif
            LazyVGrid(columns: filterColumns, alignment: .leading, content: {
                Picker(selection: $filteredProductID, label: Label(LocalizedStringKey("str.stock.journal.product"), systemImage: MySymbols.filter).fixedSize(horizontal: false, vertical: true), content: {
                    Text("str.stock.all").tag(nil as String?)
                    ForEach(grocyVM.mdProducts, id:\.id) { product in
                        Text(product.name).tag(product.id as String?)
                    }
                }).pickerStyle(MenuPickerStyle())
                Picker(selection: $filteredTransactionType, label: Label(LocalizedStringKey("str.stock.journal.transactionType"), systemImage: MySymbols.filter).fixedSize(horizontal: false, vertical: true), content: {
                    Text("str.stock.all").tag(nil as TransactionType?)
                    ForEach(TransactionType.allCases, id:\.rawValue) { transactionType in
                        Text(transactionType.formatTransactionType()).tag(transactionType as TransactionType?)
                    }
                }).pickerStyle(MenuPickerStyle())
                Picker(selection: $filteredLocationID, label: Label(LocalizedStringKey("str.stock.journal.location"), systemImage: MySymbols.filter).fixedSize(horizontal: false, vertical: true), content: {
                    Text("str.stock.all").tag(nil as String?)
                    ForEach(grocyVM.mdLocations, id:\.id) { location in
                        Text(location.name).tag(location.id as String?)
                    }
                }).pickerStyle(MenuPickerStyle())
                Picker(selection: $filteredUserID, label: Label(LocalizedStringKey("str.stock.journal.user"), systemImage: MySymbols.filter).fixedSize(horizontal: false, vertical: true), content: {
                    Text("str.stock.all").tag(nil as String?)
                    ForEach(grocyVM.users, id:\.id) { user in
                        Text(user.displayName).tag(user.id as String?)
                    }
                }).pickerStyle(MenuPickerStyle())
            })
        }
    }
}

struct StockJournalRowView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @AppStorage("localizationKey") var localizationKey: String = "en"
    
    var journalEntry: StockJournalEntry
    
    @Binding var showToastUndoFailed: Bool
    
    var quantityUnit: MDQuantityUnit {
        let product = grocyVM.mdProducts.first(where: {$0.id == journalEntry.productID})
        return grocyVM.mdQuantityUnits.first(where: {$0.id == product?.quIDStock}) ?? MDQuantityUnit(id: "0", name: "QU Error", mdQuantityUnitDescription: nil, rowCreatedTimestamp: "", namePlural: "QU Error", pluralForms: nil, userfields: nil)
    }
    
    private func undoTransaction() {
        grocyVM.undoBookingWithID(id: journalEntry.id, completion: { result in
            switch result {
            case let .success(message):
                grocyVM.postLog(message: "Undo transaction successful. \(message)", type: .info)
                grocyVM.requestData(objects: [.stock_log])
            case let .failure(error):
                grocyVM.postLog(message: "Undo transaction failed. \(error)", type: .error)
                showToastUndoFailed = true
            }
        })
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "arrow.counterclockwise")
                .padding()
                .help(LocalizedStringKey("str.stock.journal.undo"))
                .foregroundColor(Color.white)
                .background(journalEntry.undone == "1" ? Color.grocyGrayLight : Color.grocyGray)
                .cornerRadius(5)
                .onTapGesture {
                    if journalEntry.undone == "0" {
                        undoTransaction()
                    }
                }
            VStack(alignment: .leading){
                Text(grocyVM.mdProducts.first(where: { $0.id == journalEntry.productID })?.name ?? "Name Error")
                    .font(.title)
                    .strikethrough(journalEntry.undone == "1", color: .primary)
                if journalEntry.undone == "1" {
                    if let date = getDateFromTimestamp(journalEntry.undoneTimestamp ?? "") {
                        HStack(alignment: .bottom){
                            Text(LocalizedStringKey("str.stock.journal.undo.date \(formatDateAsString(date))"))
                                .font(.caption)
                            Text(getRelativeDateAsText(date, localizationKey: localizationKey))
                                .font(.caption)
                                .italic()
                        }
                        .foregroundColor(journalEntry.undone == "1" ? Color.gray : Color.primary)
                    }
                }
                Group {
                    Text(LocalizedStringKey("str.stock.journal.amount.info \("\(journalEntry.amount) \(journalEntry.amount == "1" ? quantityUnit.name : quantityUnit.namePlural)")"))
                    Text(LocalizedStringKey("str.stock.journal.transactionTime.info \(formatTimestampOutput(journalEntry.rowCreatedTimestamp))"))
                    Text(LocalizedStringKey("str.stock.journal.transactionType.info \("")"))
                        .font(.caption)
                    +
                    Text(journalEntry.transactionType.formatTransactionType())
                        .font(.caption)
                    Text(LocalizedStringKey("str.stock.journal.location.info \(grocyVM.mdLocations.first(where: {$0.id == journalEntry.locationID})?.name ?? "Location Error")"))
                    Text(LocalizedStringKey("str.stock.journal.user.info \(grocyVM.users.first(where: { $0.id == journalEntry.userID })?.displayName ?? "Username Error")"))
                }
                .foregroundColor(journalEntry.undone == "1" ? Color.gray : Color.primary)
                .font(.caption)
            }
            Spacer()
        }
    }
}

struct StockJournalView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    @Environment(\.dismiss) var dismiss
    
    @State private var searchString: String = ""
    
    @State private var filteredProductID: String?
    @State private var filteredLocationID: String?
    @State private var filteredTransactionType: TransactionType?
    @State private var filteredUserID: String?
    
    @State private var showToastUndoFailed: Bool = false
    
    var selectedProductID: String?
    
    var filteredJournal: StockJournal {
        grocyVM.stockJournal
            .filter { journalEntry in
                !searchString.isEmpty ? grocyVM.mdProducts.first(where: { product in
                    product.name.localizedCaseInsensitiveContains(searchString)
                })?.id == journalEntry.productID : true
            }
            .filter { journalEntry in
                filteredProductID == nil ? true : (journalEntry.productID == filteredProductID)
            }
            .filter { journalEntry in
                filteredLocationID == nil ? true : (journalEntry.locationID == filteredLocationID)
            }
            .filter { journalEntry in
                filteredTransactionType == nil ? true : (journalEntry.transactionType == filteredTransactionType)
            }
            .filter { journalEntry in
                filteredUserID == nil ? true : (journalEntry.userID == filteredUserID)
            }
            .sorted {
                $0.rowCreatedTimestamp > $1.rowCreatedTimestamp
            }
    }
    
    private func updateData() {
        grocyVM.requestData(objects: [.stock_log], additionalObjects: [.users])
    }
    
    var body: some View {
#if os(iOS)
        NavigationView {
            content
                .padding()
                .toolbar(content: {
                    ToolbarItem(placement: .cancellationAction, content: { Button("str.close", role: .cancel, action: { dismiss() }) })
                })
        }
#else
        content
#endif
    }
    
    var content: some View {
        List{
            Section {
                StockJournalFilterBar(filteredProductID: $filteredProductID, filteredTransactionType: $filteredTransactionType, filteredLocationID: $filteredLocationID, filteredUserID: $filteredUserID)
            }
            Section {
                if grocyVM.stockJournal.isEmpty {
                    Text(LocalizedStringKey("str.stock.journal.empty")).padding()
                } else if filteredJournal.isEmpty {
                    Text(LocalizedStringKey("str.noSearchResult")).padding()
                }
                ForEach(filteredJournal, id: \.id) { journalEntry in
                    StockJournalRowView(journalEntry: journalEntry, showToastUndoFailed: $showToastUndoFailed)
                }
            }
            
        }
        .searchable(LocalizedStringKey("str.search"), text: $searchString)
        .refreshable(action: updateData)
        .onAppear(perform: {
            grocyVM.requestData(objects: [.stock_log], additionalObjects: [.users], ignoreCached: false)
            filteredProductID = selectedProductID
        })
        .toast(isPresented: $showToastUndoFailed, isSuccess: false, content: {
            Label(LocalizedStringKey("str.stock.journal.undo.failed"), systemImage: MySymbols.failure)
        })
        .navigationTitle(LocalizedStringKey("str.stock.journal"))
    }
}

struct StockJournalView_Previews: PreviewProvider {
    static var previews: some View {
        StockJournalView()
    }
}
