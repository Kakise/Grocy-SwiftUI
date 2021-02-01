//
//  QuickScanModeSelectProductView.swift
//  Grocy-SwiftUI (iOS)
//
//  Created by Georg Meissner on 21.01.21.
//

import SwiftUI

struct QuickScanModeSelectProductView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var firstOpen: Bool = true
    
    @Binding var barcode: String?
    
    @State private var productID: String?
    
    @Binding var toastType: QSToastType?
    
    private func resetForm() {
        productID = nil
    }
    
    private func updateData() {
        grocyVM.getMDProductBarcodes()
    }
    
    private func finishForm() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func addBarcodeForProduct() {
        if let barcode = barcode {
            if let productID = productID {
                let newBarcode = MDProductBarcode(id: String(grocyVM.findNextID(.product_barcodes)), productID: productID, barcode: barcode, quID: nil, amount: nil, shoppingLocationID: nil, lastPrice: nil, rowCreatedTimestamp: Date().iso8601withFractionalSeconds, note: nil, userfields: nil)
                grocyVM.postMDObject(object: .product_barcodes, content: newBarcode, completion: { result in
                    switch result {
                    case let .success(message):
                        print(message)
                        toastType = .successQSAddProduct
                        resetForm()
                        updateData()
                        finishForm()
                    case let .failure(error):
                        print("\(error)")
                        toastType = .failQSAddProduct
                    }
                })
            }
        }
    }
    
    var body: some View {
        NavigationView{
            Form {
                Section(){
                    Text(barcode ?? "barcode").font(.title)
                }
                ProductField(productID: $productID, description: "str.quickScan.add.product")
            }
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction, content: {
                    Button(LocalizedStringKey("str.cancel")) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                })
                ToolbarItem(placement: .automatic, content: {
                    Button(action: addBarcodeForProduct, label: {
                        Label(LocalizedStringKey("str.quickScan.add.product.add"), systemImage: "plus")
                            .labelStyle(TextIconLabelStyle())
                    })
                    .disabled(productID == nil)
                    .keyboardShortcut(.defaultAction)
                })
            })
        }
    }
}

struct QuickScanModeSelectProductView_Previews: PreviewProvider {
    static var previews: some View {
        QuickScanModeSelectProductView(barcode: Binding.constant("12345"), toastType: Binding.constant(.successQSAddProduct))
    }
}