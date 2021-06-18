//
//  ProductField.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 13.01.21.
//

import SwiftUI

struct ProductField: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @Binding var productID: String?
    var description: String
    
    @State private var searchTerm: String = ""
#if os(iOS)
    @State private var isShowingScanner: Bool = false
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        switch result {
        case .success(let code):
            searchTerm = code
        case .failure(let error):
            grocyVM.postLog(message: "Scanning for product failed. \(error)", type: .error)
        }
    }
#endif
    
    private func getBarcodes(pID: String) -> [String] {
        grocyVM.mdProductBarcodes.filter{$0.productID == pID}.map{$0.barcode}
    }
    
    private var sortedProducts: MDProducts {
        grocyVM.mdProducts.sorted(by: {$0.name < $1.name})
    }
    
    private var filteredProducts: MDProducts {
        sortedProducts.filter {
            searchTerm.isEmpty ? true : ($0.name.localizedCaseInsensitiveContains(searchTerm) || getBarcodes(pID: $0.id).contains(searchTerm))
        }
    }
    
    var body: some View {
        Picker(selection: $productID, label: Label(LocalizedStringKey(description), systemImage: MySymbols.product).foregroundColor(.primary), content: {
#if os(iOS)
            Button(action: {
                isShowingScanner.toggle()
            }, label: {
                Label(LocalizedStringKey("str.quickScan.barcode.search"), systemImage: MySymbols.barcodeScan)
            })
                .sheet(isPresented: $isShowingScanner, content: {
                    CodeScannerView(codeTypes: [.ean8, .ean13], scanMode: .once, simulatedData: "5901234123457", completion: self.handleScan)
                })
#endif
            Text("")
                .tag(nil as String?)
            ForEach(filteredProducts, id: \.id, content: { productElement in
                Text(productElement.name)
                    .tag(productElement.id as String?)
            })
//                .searchable("str.search", text: $searchTerm)
        })
    }
}

struct ProductField_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            Form{
                ProductField(productID: Binding.constant("1"), description: "str.stock.buy.product")
            }
        }
    }
}
