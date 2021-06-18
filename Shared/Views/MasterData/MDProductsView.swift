//
//  MDProductsView.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 17.11.20.
//

import SwiftUI

struct MDProductRowView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    var product: MDProduct
    
    var body: some View {
        HStack{
            if let pictureFileName = product.pictureFileName, !pictureFileName.isEmpty, let base64Encoded = pictureFileName.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)), let pictureURL = grocyVM.getPictureURL(groupName: "productpictures", fileName: base64Encoded), let url = URL(string: pictureURL) {
                AsyncImage(url: url, content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(Color.white)
                }, placeholder: {
                    ProgressView().progressViewStyle(.circular)
                })
                    .frame(width: 75, height: 75)
            }
            VStack(alignment: .leading) {
                Text(product.name).font(.largeTitle)
                HStack(alignment: .top){
                    if let locationID = GrocyViewModel.shared.mdLocations.firstIndex { $0.id == product.locationID } {
                        Text(LocalizedStringKey("str.md.product.rowLocation \(grocyVM.mdLocations[locationID].name)"))
                            .font(.caption)
                    }
                    if let productGroup = GrocyViewModel.shared.mdProductGroups.firstIndex { $0.id == product.productGroupID } {
                        Text(LocalizedStringKey("str.md.product.rowProductGroup \(grocyVM.mdProductGroups[productGroup].name)"))
                            .font(.caption)
                    }
                }
                if let description = product.mdProductDescription, !description.isEmpty {
                    Text(description).font(.caption).italic()
                }
            }
        }
    }
}

struct MDProductsView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @Environment(\.dismiss) var dismiss
    
    @State private var searchString: String = ""
    @State private var showAddProduct: Bool = false
    
    @State private var productToDelete: MDProduct? = nil
    @State private var showDeleteAlert: Bool = false
    
    @State private var toastType: MDToastType?
    
    private func updateData() {
        grocyVM.requestData(objects: [.products, .locations, .product_groups])
    }
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            productToDelete = filteredProducts[offset]
            showDeleteAlert.toggle()
        }
    }
    private func deleteProduct(toDelID: String) {
        grocyVM.deleteMDObject(object: .products, id: toDelID, completion: { result in
            switch result {
            case let .success(message):
                print(message)
                updateData()
            case let .failure(error):
                print("\(error)")
                toastType = .failDelete
            }
        })
    }
    
    private var filteredProducts: MDProducts {
        grocyVM.mdProducts
            .filter {
                searchString.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchString)
            }
            .sorted {
                $0.name < $1.name
            }
    }
    
    var body: some View {
        if grocyVM.failedToLoadObjects.count == 0 && grocyVM.failedToLoadAdditionalObjects.count == 0 {
            bodyContent
        } else {
            ServerOfflineView()
                .navigationTitle(LocalizedStringKey("str.md.products"))
        }
    }
    
#if os(macOS)
    var bodyContent: some View {
        NavigationView{
            content
                .toolbar (content: {
                    ToolbarItem(placement: .primaryAction, content: {
                        Button(action: {
                            showAddProduct.toggle()
                        }, label: {Image(systemName: MySymbols.new)})
                    })
                })
                .frame(minWidth: Constants.macOSNavWidth)
        }
        .navigationTitle(LocalizedStringKey("str.md.products"))
    }
#elseif os(iOS)
    var bodyContent: some View {
        content
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showAddProduct.toggle()
                    }, label: {Image(systemName: MySymbols.new)})
                }
            }
            .navigationTitle(LocalizedStringKey("str.md.products"))
            .sheet(isPresented: $showAddProduct, content: {
                NavigationView {
                    MDProductFormView(isNewProduct: true, showAddProduct: $showAddProduct, toastType: $toastType)
                }
            })
    }
#endif
    
    var content: some View {
        List(){
            if grocyVM.mdProducts.isEmpty {
                Text(LocalizedStringKey("str.md.products.empty"))
            } else if filteredProducts.isEmpty {
                Text(LocalizedStringKey("str.noSearchResult"))
            }
#if os(macOS)
            if showAddProduct {
                NavigationLink(destination: MDProductFormView(isNewProduct: true, showAddProduct: $showAddProduct, toastType: $toastType), isActive: $showAddProduct, label: {
                    NewMDRowLabel(title: "str.md.product.new")
                })
            }
#endif
            ForEach(filteredProducts, id:\.id) { product in
                NavigationLink(destination: MDProductFormView(isNewProduct: false, product: product, showAddProduct: Binding.constant(false), toastType: $toastType)) {
                    MDProductRowView(product: product)
                }
            }
            .onDelete(perform: delete)
        }
        .onAppear(perform: {
            grocyVM.requestData(objects: [.products, .locations, .product_groups], ignoreCached: false)
        })
        .searchable(LocalizedStringKey("str.search"), text: $searchString)
        .refreshable(action: updateData)
        .animation(.default, value: filteredProducts.count)
        .toast(item: $toastType, isSuccess: Binding.constant(toastType == .successAdd || toastType == .successEdit), content: { item in
            switch item {
            case .successAdd:
                Label(LocalizedStringKey("str.md.new.success"), systemImage: MySymbols.success)
            case .failAdd:
                Label(LocalizedStringKey("str.md.new.fail"), systemImage: MySymbols.failure)
            case .successEdit:
                Label(LocalizedStringKey("str.md.edit.success"), systemImage: MySymbols.success)
            case .failEdit:
                Label(LocalizedStringKey("str.md.edit.fail"), systemImage: MySymbols.failure)
            case .failDelete:
                Label(LocalizedStringKey("str.md.delete.fail"), systemImage: MySymbols.failure)
            }
        })
        .alert(LocalizedStringKey("str.md.product.delete.confirm"), isPresented: $showDeleteAlert, actions: {
            Button(LocalizedStringKey("str.cancel"), role: .cancel) { }
            Button(LocalizedStringKey("str.delete"), role: .destructive) {
                deleteProduct(toDelID: productToDelete?.id ?? "")
            }
        }, message: { Text(productToDelete?.name ?? "error") })
    }
}

struct MDProductsView_Previews: PreviewProvider {
    static var previews: some View {
#if os(macOS)
        MDProductsView()
#else
        NavigationView() {
            MDProductsView()
        }
#endif
    }
}
