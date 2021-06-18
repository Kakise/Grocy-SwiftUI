//
//  MDBarcodesView.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 03.12.20.
//

import SwiftUI

struct MDBarcodeRowView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    var barcode: MDProductBarcode
    
    var shoppingLocationName: String? {
        grocyVM.mdShoppingLocations.first(where: {$0.id == barcode.shoppingLocationID})?.name
    }
    var quIDName: String? {
        grocyVM.mdQuantityUnits.first(where: {$0.id == barcode.quID})?.name
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Text(barcode.barcode)
                .font(.title)
            HStack{
                if let amount = barcode.amount {
                    Text(LocalizedStringKey("str.md.barcode.info.amount \("\(formatStringAmount(amount)) \(quIDName ?? barcode.quID ?? "noQU")")"))
                }
                if let storeName = shoppingLocationName {
                    Text(LocalizedStringKey("str.md.barcode.info.store \(storeName)"))
                }
            }.font(.caption)
        }
    }
}

struct MDBarcodesView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    var productID: String
    
    @State private var showAddBarcode: Bool = false
    
    @State private var barcodeToDelete: MDProductBarcode? = nil
    @State private var showDeleteAlert: Bool = false
    
    @Binding var toastType: MDToastType?
    
    private func updateData() {
        grocyVM.requestData(objects: [.product_barcodes])
    }
    
    var filteredBarcodes: MDProductBarcodes {
        grocyVM.mdProductBarcodes
    }
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            barcodeToDelete = filteredBarcodes[offset]
            showDeleteAlert.toggle()
        }
    }
    private func deleteBarcode(toDelID: String) {
        grocyVM.deleteMDObject(object: .product_barcodes, id: toDelID, completion: { result in
                        switch result {
                        case let .success(message):
                            grocyVM.postLog(message: "Barcode delete successful. \(message)", type: .info)
                            updateData()
                        case let .failure(error):
                            grocyVM.postLog(message: "Barcode delete failed. \(error)", type: .error)
                            toastType = .failDelete
                        }
                    })
    }
    
    var body: some View {
        if grocyVM.failedToLoadObjects.count == 0 && grocyVM.failedToLoadAdditionalObjects.count == 0 {
            bodyContent
        } else {
            ServerOfflineView()
                .navigationTitle(LocalizedStringKey("str.md.barcodes"))
        }
    }
    
    #if os(macOS)
    var bodyContent: some View {
        Section(header: Text(LocalizedStringKey("str.md.barcodes")).font(.headline)) {
            
            Button(action: {showAddBarcode.toggle()}, label: {Image(systemName: MySymbols.new)})
                .popover(isPresented: $showAddBarcode, content: {
                    MDBarcodeFormView(isNewBarcode: true, productID: productID, toastType: $toastType)
                })
            if filteredBarcodes.isEmpty {
                Text(LocalizedStringKey("str.md.barcodes.empty"))
            }
            NavigationView{
                List{
                    ForEach(filteredBarcodes, id:\.id) {productBarcode in
                        NavigationLink(
                            destination: ScrollView{
                                MDBarcodeFormView(isNewBarcode: false, productID: productID, editBarcode: productBarcode, toastType: $toastType)
                            },
                            label: {
                                MDBarcodeRowView(barcode: productBarcode)
                            })
                    }.onDelete(perform: delete)
                }
                .frame(minWidth: 200, minHeight: 400)
            }
        }
        .onAppear(perform: { grocyVM.requestData(objects: [.product_barcodes], ignoreCached: false) })
    }
    #elseif os(iOS)
    var bodyContent: some View {
        Form {
            if filteredBarcodes.isEmpty {
                Text(LocalizedStringKey("str.md.barcodes.empty"))
            } else {
                ForEach(filteredBarcodes, id:\.id) {productBarcode in
                    NavigationLink(
                        destination: MDBarcodeFormView(isNewBarcode: false, productID: productID, editBarcode: productBarcode, toastType: $toastType),
                        label: {
                            MDBarcodeRowView(barcode: productBarcode)
                        })
                }.onDelete(perform: delete)
            }
        }
        .navigationTitle(LocalizedStringKey("str.md.barcodes"))
        .onAppear(perform: {
            grocyVM.requestData(objects: [.product_barcodes], ignoreCached: false)
        })
        .refreshable(action: updateData)
        .animation(.default, value: filteredBarcodes.count)
        .toolbar(content: {
            ToolbarItem(placement: .automatic, content: {
                Button(action: {showAddBarcode.toggle()}, label: {
                    Label("str.md.barcode.new", systemImage: "plus")
                        .labelStyle(.titleAndIcon)
                })
            })
        })
        .alert(LocalizedStringKey("str.md.barcode.delete.confirm"), isPresented: $showDeleteAlert, actions: {
            Button(LocalizedStringKey("str.cancel"), role: .cancel) { }
            Button(LocalizedStringKey("str.delete"), role: .destructive) {
                deleteBarcode(toDelID: barcodeToDelete?.id ?? "")
            }
        }, message: { Text(barcodeToDelete?.barcode ?? "error") })
        .sheet(isPresented: $showAddBarcode, content: {
            NavigationView{
                MDBarcodeFormView(isNewBarcode: true, productID: productID, toastType: $toastType)
            }
        })
    }
    #endif
}

struct MDBarcodesView_Previews: PreviewProvider {
    @StateObject var grocyVM: GrocyViewModel = .shared
    static var previews: some View {
        NavigationView{
            MDBarcodesView(productID: "27", toastType: Binding.constant(nil))
        }
    }
}
