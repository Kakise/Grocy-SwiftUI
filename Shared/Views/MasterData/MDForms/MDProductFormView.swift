//
//  MDProductFormView.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 19.11.20.
//

import SwiftUI

struct MDProductFormView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("devMode") private var devMode: Bool = false
    
    @State private var firstAppear: Bool = true
    @State private var isProcessing: Bool = false
    
    @State private var name: String = "" // REQUIRED
    @State private var active: Bool = true
    @State private var parentProductID: String?
    @State private var mdProductDescription: String = ""
    
    @State private var selectedPictureURL: URL? = nil
    @State private var selectedPictureFileName: String? = nil
    
    @State private var locationID: String? // REQUIRED
    @State private var shoppingLocationID: String?
    @State private var minStockAmount: Double = 0.0
    @State private var cumulateMinStockAmountOfSubProducts: Bool = false
    @State private var dueType: DueType = DueType.bestBefore
    @State private var defaultDueDays: Int = 0
    @State private var defaultDueDaysAfterOpen: Int = 0
    @State private var productGroupID: String = ""
    @State private var quIDStock: String? // REQUIRED
    @State private var quIDPurchase: String? // REQUIRED
    @State private var quFactorPurchaseToStock: Double = 1.0
    @State private var enableTareWeightHandling: Bool = false
    @State private var tareWeight: Double = 0.0
    @State private var notCheckStockFulfillmentForRecipes: Bool = false
    @State private var calories: Double = 0.0
    @State private var defaultDueDaysAfterFreezing: Int = 0
    @State private var defaultDueDaysAfterThawing: Int = 0
    @State private var quickConsumeAmount: Double = 1.0
    @State private var hideOnStockOverview: Bool = false
    
    @State private var showDeleteAlert: Bool = false
    @State private var showOFFResult: Bool = false
    
    var isNewProduct: Bool
    var product: MDProduct?
    
    @Binding var showAddProduct: Bool
    @Binding var toastType: MDToastType?
    
    @State var isNameCorrect: Bool = true
    private func checkNameCorrect() -> Bool {
        let foundProduct = grocyVM.mdProducts.first(where: {$0.name == name})
        return isNewProduct ? !(name.isEmpty || foundProduct != nil) : !(name.isEmpty || (foundProduct != nil && foundProduct!.id != product!.id))
    }
    
    private var currentQUPurchase: MDQuantityUnit? {
        return grocyVM.mdQuantityUnits.first(where: {$0.id == quIDPurchase})
    }
    private var currentQUStock: MDQuantityUnit? {
        return grocyVM.mdQuantityUnits.first(where: {$0.id == quIDStock})
    }
    
    private func resetForm() {
        name = product?.name ?? ""
        
        active = (product?.active ?? "1") == "1"
        parentProductID = product?.parentProductID
        mdProductDescription = product?.mdProductDescription ?? ""
        productGroupID = product?.productGroupID ?? ""
        calories = Double(product?.calories ?? "") ?? 0.0
        hideOnStockOverview = (product?.hideOnStockOverview ?? "0") == "1"
        selectedPictureFileName = product?.pictureFileName
        
        locationID = product?.locationID
        shoppingLocationID = product?.shoppingLocationID
        
        dueType = product?.dueType == DueType.bestBefore.rawValue ? DueType.bestBefore : DueType.expires
        defaultDueDays = Int(product?.defaultBestBeforeDays ?? "") ?? 0
        defaultDueDaysAfterOpen = Int(product?.defaultBestBeforeDaysAfterOpen ?? "") ?? 0
        defaultDueDaysAfterFreezing = Int(product?.defaultBestBeforeDaysAfterThawing ?? "") ?? 0
        defaultDueDaysAfterThawing = Int(product?.defaultBestBeforeDaysAfterThawing ?? "") ?? 0
        
        quIDStock = product?.quIDStock
        quIDPurchase = product?.quIDPurchase
        
        minStockAmount = Double(product?.minStockAmount ?? "") ?? 0.0
        cumulateMinStockAmountOfSubProducts = ((product?.cumulateMinStockAmountOfSubProducts ?? "") as NSString).boolValue
        quickConsumeAmount = Double(product?.quickConsumeAmount ?? "") ?? 1.0
        quFactorPurchaseToStock = Double(product?.quFactorPurchaseToStock ?? "") ?? 1.0
        enableTareWeightHandling = (product?.enableTareWeightHandling ?? "0") == "1"
        tareWeight = Double(product?.tareWeight ?? "") ?? 0.0
        notCheckStockFulfillmentForRecipes = (product?.notCheckStockFulfillmentForRecipes ?? "0") == "1"
        
        isNameCorrect = checkNameCorrect()
    }
    
    private func updateData() {
        grocyVM.requestData(objects: [.products, .quantity_units, .locations, .shopping_locations])
    }
    
    private func finishForm() {
#if os(iOS)
        dismiss()
#elseif os(macOS)
        if isNewProduct {
            showAddProduct = false
        }
#endif
    }
    
    private var isFormValid: Bool {
        !(name.isEmpty) && isNameCorrect && (locationID != nil) && (quIDStock != nil) && (quIDPurchase != nil)
    }
    
    private func saveProduct() {
        if let locationID = locationID, let quIDPurchase = quIDPurchase, let quIDStock = quIDStock {
            let id = isNewProduct ? String(grocyVM.findNextID(.products)) : product!.id
            let timeStamp = isNewProduct ? Date().iso8601withFractionalSeconds : product!.rowCreatedTimestamp
            let productPOST = MDProduct(id: id, name: name, mdProductDescription: mdProductDescription, productGroupID: productGroupID, active: active ? "1" : "0", locationID: locationID, shoppingLocationID: shoppingLocationID, quIDPurchase: quIDPurchase, quIDStock: quIDStock, quFactorPurchaseToStock: String(quFactorPurchaseToStock), minStockAmount: String(minStockAmount), defaultBestBeforeDays: String(defaultDueDays), defaultBestBeforeDaysAfterOpen: String(defaultDueDaysAfterOpen), defaultBestBeforeDaysAfterFreezing: String(defaultDueDaysAfterFreezing), defaultBestBeforeDaysAfterThawing: String(defaultDueDaysAfterThawing), pictureFileName: product?.pictureFileName, enableTareWeightHandling: enableTareWeightHandling ? "1" : "0", tareWeight: String(tareWeight), notCheckStockFulfillmentForRecipes: notCheckStockFulfillmentForRecipes ? "1" : "0", parentProductID: parentProductID, calories: String(calories), cumulateMinStockAmountOfSubProducts: cumulateMinStockAmountOfSubProducts ? "1" : "0", dueType: dueType.rawValue, quickConsumeAmount: String(quickConsumeAmount), rowCreatedTimestamp: timeStamp, hideOnStockOverview: hideOnStockOverview ? "1" : "0", userfields: nil)
            isProcessing = true
            if isNewProduct {
                grocyVM.postMDObject(object: .products, content: productPOST, completion: { result in
                    switch result {
                    case let .success(message):
                        grocyVM.postLog(message: "Product add successful. \(message)", type: .info)
                        toastType = .successAdd
                        updateData()
                        finishForm()
                    case let .failure(error):
                        grocyVM.postLog(message: "Product add failed. \(error)", type: .error)
                        toastType = .failAdd
                    }
                    isProcessing = false
                })
            } else {
                grocyVM.putMDObjectWithID(object: .products, id: id, content: productPOST, completion: { result in
                    switch result {
                    case let .success(message):
                        grocyVM.postLog(message: "Product edit successful. \(message)", type: .info)
                        toastType = .successEdit
                        updateData()
                        finishForm()
                    case let .failure(error):
                        grocyVM.postLog(message: "Product edit failed. \(error)", type: .error)
                        toastType = .failEdit
                    }
                    isProcessing = false
                })
            }
        }
    }
    
    var body: some View {
#if os(macOS)
        NavigationView{
            content
                .padding()
        }
#elseif os(iOS)
        content
            .navigationTitle(isNewProduct ? LocalizedStringKey("str.md.product.new") : LocalizedStringKey("str.md.product.edit"))
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedStringKey("str.cancel"), role: .cancel, action: finishForm)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("str.md.product.save")) {
                        saveProduct()
                    }
                    .disabled(!isFormValid || isProcessing)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    // Back not shown without it
                    if !isNewProduct{
                        Text("")
                    }
                }
            })
#endif
    }
    
    var content: some View {
        Form {
#if os(iOS)
            if devMode && isNewProduct {
                Button(action: {
                    showOFFResult.toggle()
                }, label: {Label("FILL WITH OFF", systemImage: "plus")})
                    .popover(isPresented: $showOFFResult, content: {
                        OpenFoodFactsScannerView()
                            .frame(width: 500, height: 500)
                    })
            }
#endif
            
            
            MyTextField(textToEdit: $name, description: "str.md.product.name", isCorrect: $isNameCorrect, leadingIcon: "tag", emptyMessage: "str.md.product.name.required", errorMessage: "str.md.product.name.exists")
                .onChange(of: name, perform: { value in
                    isNameCorrect = checkNameCorrect()
                })
            
            Section {
                
#if os(macOS)
                if #available(OSX 11.3, *) {
                    Text("Navigation currently not working on macOS Big Sur 11.3 and up. It worked in previous versions.")
                        .foregroundColor(Color.red)
                }
                NavigationLink(
                    destination: NavigationView{optionalPropertiesView},
                    label: {
                    MyLabelWithSubtitle(title: "str.md.product.category.optionalProperties", subTitle: "str.md.product.category.optionalProperties.description", systemImage: MySymbols.description)
                })
#else
                NavigationLink(
                    destination: optionalPropertiesView,
                    label: {
                    MyLabelWithSubtitle(title: "str.md.product.category.optionalProperties", subTitle: "str.md.product.category.optionalProperties.description", systemImage: MySymbols.description)
                })
#endif
                
                NavigationLink(
                    destination: locationPropertiesView,
                    label: {
                    MyLabelWithSubtitle(title: "str.md.product.category.defaultLocations", subTitle: "str.md.product.category.defaultLocations.description", systemImage: MySymbols.location, isProblem: locationID == nil)
                })
                
                NavigationLink(
                    destination: dueDatePropertiesView,
                    label: {
                    MyLabelWithSubtitle(title: "str.md.product.category.dueDate", subTitle: "str.md.product.category.dueDate.description", systemImage: MySymbols.date)
                })
                
                NavigationLink(
                    destination: quantityUnitPropertiesView,
                    label: {
                    MyLabelWithSubtitle(title: "str.md.product.category.quantityUnits", subTitle: "str.md.product.category.quantityUnits.description", systemImage: MySymbols.quantityUnit, isProblem: (quIDStock == nil || quIDPurchase == nil))
                })
                
                NavigationLink(
                    destination: amountPropertiesView,
                    label: {
                    MyLabelWithSubtitle(title: "str.md.product.category.amount", subTitle: "str.md.product.category.amount.description", systemImage: MySymbols.amount)
                })
                
                NavigationLink(
                    destination: barcodePropertiesView,
                    label: {
                    MyLabelWithSubtitle(title: "str.md.barcodes", subTitle: isNewProduct ? "str.md.product.notOnServer" : "", systemImage: MySymbols.barcode, hideSubtitle: !isNewProduct)
                })
                    .disabled(isNewProduct)
            }
            
#if os(macOS)
            HStack{
                Button(LocalizedStringKey("str.cancel"), role: .cancel) {
                    if isNewProduct{
                        finishForm()
                    } else {
                        resetForm()
                    }
                }
                .keyboardShortcut(.cancelAction)
                Spacer()
                Button(LocalizedStringKey("str.save")) {
                    saveProduct()
                }
                .disabled(!isFormValid || isProcessing)
                .keyboardShortcut(.defaultAction)
            }
#endif
        }
        .onAppear(perform: {
            if firstAppear {
                grocyVM.requestData(objects: [.products, .quantity_units, .locations, .shopping_locations], ignoreCached: false)
                resetForm()
                firstAppear = false
            }
        })
    }
    
    var optionalPropertiesView: some View {
        Form{
            // Active
            MyToggle(isOn: $active, description: "str.md.product.active", descriptionInfo: nil, icon: "checkmark.circle")
            
            // Parent Product
            ProductField(productID: $parentProductID, description: "str.md.product.parentProduct")
            
            // Product Description
            MyTextField(textToEdit: $mdProductDescription, description: "str.md.product.description", isCorrect: Binding.constant(true), leadingIcon: MySymbols.description)
            
            // Product group
            Picker(selection: $productGroupID, label: Label(LocalizedStringKey("str.md.product.productGroup"), systemImage: MySymbols.productGroup).foregroundColor(.primary), content: {
                Text("").tag("")
                ForEach(grocyVM.mdProductGroups, id:\.id) { grocyProductGroup in
                    Text(grocyProductGroup.name).tag(grocyProductGroup.id)
                }
            })
            
            // Energy
            MyDoubleStepper(amount: $calories, description: "str.md.product.calories", descriptionInfo: "str.md.product.calories.info", minAmount: 0, amountStep: 1, amountName: "kcal", errorMessage: "str.md.product.calories.invalid", systemImage: MySymbols.energy)
            
            // Don't show on stock overview
            MyToggle(isOn: $hideOnStockOverview, description: "str.md.product.dontShowOnStockOverview", descriptionInfo: "str.md.product.dontShowOnStockOverview.info", icon: MySymbols.stockOverview)
            
            // Product picture
            NavigationLink(destination: MDProductPictureFormView(product: product, selectedPictureURL: $selectedPictureURL, selectedPictureFileName: $selectedPictureFileName), label: {
                MyLabelWithSubtitle(title: "str.md.product.picture", subTitle: (product?.pictureFileName ?? "").isEmpty ? "str.md.product.picture.none" : "str.md.product.picture.saved", systemImage: MySymbols.picture)
            })
                .disabled(isNewProduct)
        }
        .navigationTitle(LocalizedStringKey("str.md.product.category.optionalProperties"))
    }
    var locationPropertiesView: some View {
        Form {
            // Default Location - REQUIRED
            Picker(selection: $locationID, label: MyLabelWithSubtitle(title: "str.md.product.location", subTitle: "str.md.product.location.required", systemImage: MySymbols.location, isSubtitleProblem: true, hideSubtitle: locationID != nil), content: {
                ForEach(grocyVM.mdLocations, id:\.id) { grocyLocation in
                    Text(grocyLocation.name).tag(grocyLocation.id as String?)
                }
            })
            
            // Default Shopping Location
            Picker(selection: $shoppingLocationID, label: MyLabelWithSubtitle(title: "str.md.product.shoppingLocation", systemImage: MySymbols.shoppingLocation, hideSubtitle: true), content: {
                Text("").tag(nil as String?)
                ForEach(grocyVM.mdShoppingLocations, id:\.id) { grocyShoppingLocation in
                    Text(grocyShoppingLocation.name).tag(grocyShoppingLocation.id as String?)
                }
            })
        }
        .navigationTitle(LocalizedStringKey("str.md.product.category.defaultLocations"))
    }
    var dueDatePropertiesView: some View {
        Form {
            VStack(alignment: .leading){
                Text(LocalizedStringKey("str.md.product.dueType"))
                    .font(.headline)
                // Due Type, default best before
                Picker("", selection: $dueType, content: {
                    Text("str.md.product.dueType.bestBefore").tag(DueType.bestBefore)
                    Text("str.md.product.dueType.expires").tag(DueType.expires)
                }).pickerStyle(SegmentedPickerStyle())
            }
            
            // Default due days
            MyIntStepper(amount: $defaultDueDays, description: "str.md.product.defaultDueDays", helpText: "str.md.product.defaultDueDays.info", minAmount: 0, amountName: defaultDueDays == 1 ? "str.day" : "str.days", systemImage: MySymbols.date)
            
            // Default due days afer opening
            MyIntStepper(amount: $defaultDueDaysAfterOpen, description: "str.md.product.defaultDueDaysAfterOpen", helpText: "str.md.product.defaultDueDaysAfterOpen.info", minAmount: 0, amountName: defaultDueDaysAfterOpen == 1 ? "str.day" : "str.days", systemImage: MySymbols.date)
            
            // Default due days after freezing
            MyIntStepper(amount: $defaultDueDaysAfterFreezing, description: "str.md.product.defaultDueDaysAfterFreezing", helpText: "str.md.product.defaultDueDaysAfterFreezing.info", minAmount: -1, amountName: defaultDueDaysAfterFreezing == 1 ? "str.day" : "str.days", errorMessage: "str.md.product.defaultDueDaysAfterFreezing.invalid", systemImage: MySymbols.freezing)
            
            // Default due days after thawing
            MyIntStepper(amount: $defaultDueDaysAfterThawing, description: "str.md.product.defaultDueDaysAfterThawing", helpText: "str.md.product.defaultDueDaysAfterThawing.info", minAmount: 0, amountName: defaultDueDaysAfterThawing == 1 ? "str.day" : "str.days", errorMessage: "str.md.product.defaultDueDaysAfterThawing.invalid", systemImage: MySymbols.thawing)
        }
        .navigationTitle(LocalizedStringKey("str.md.product.category.dueDate"))
    }
    var quantityUnitPropertiesView: some View {
        Form {
            // QU Stock - REQUIRED
            HStack{
                Picker(selection: $quIDStock, label: MyLabelWithSubtitle(title: "str.md.product.quStock", subTitle: "str.md.product.quStock.required", systemImage: MySymbols.quantityUnit, isSubtitleProblem: true, hideSubtitle: quIDStock != nil), content: {
                    ForEach(grocyVM.mdQuantityUnits, id:\.id) { grocyQuantityUnit in
                        Text(grocyQuantityUnit.name).tag(grocyQuantityUnit.id as String?)
                    }
                })
                    .onChange(of: quIDStock, perform: { newValue in
                        if quIDPurchase == nil { quIDPurchase = quIDStock }
                    })
                
                FieldDescription(description: "str.md.product.quStock.info")
            }
            
            // QU Purchase - REQUIRED
            HStack{
                Picker(selection: $quIDPurchase, label: MyLabelWithSubtitle(title: "str.md.product.quPurchase", subTitle: "str.md.product.quPurchase.required", systemImage: MySymbols.quantityUnit, isSubtitleProblem: true, hideSubtitle: quIDPurchase != nil), content: {
                    ForEach(grocyVM.mdQuantityUnits, id:\.id) { grocyQuantityUnit in
                        Text(grocyQuantityUnit.name).tag(grocyQuantityUnit.id as String?)
                    }
                })
                FieldDescription(description: "str.md.product.quPurchase.info")
            }
        }
        .navigationTitle(LocalizedStringKey("str.md.product.category.quantityUnits"))
    }
    var amountPropertiesView: some View {
        Form {
            // Min Stock amount
            MyDoubleStepper(amount: $minStockAmount, description: "str.md.product.minStockAmount", minAmount: 0, amountStep: 1, amountName: currentQUStock?.name ?? "QU", errorMessage: "str.md.product.minStockAmount.invalid", systemImage: MySymbols.amount)
            
            // Accumulate sub products min stock amount
            MyToggle(isOn: $cumulateMinStockAmountOfSubProducts, description: "str.md.product.cumulateMinStockAmountOfSubProducts", descriptionInfo: "str.md.product.cumulateMinStockAmountOfSubProducts.info", icon: MySymbols.accumulate)
            
            // Quick consume amount
            MyDoubleStepper(amount: $quickConsumeAmount, description: "str.md.product.quickConsumeAmount", descriptionInfo: "str.md.product.quickConsumeAmount.info", minAmount: 0.0001, amountStep: 1.0, amountName: nil, errorMessage: "str.md.product.quickConsumeAmount.invalid", systemImage: MySymbols.consume)
            
            // QU Factor to stock
            VStack(alignment: .trailing) {
                MyDoubleStepper(amount: $quFactorPurchaseToStock, description: "str.md.product.quFactorPurchaseToStock", minAmount: 0.0001, amountStep: 1.0, amountName: "", errorMessage: "str.md.product.quFactorPurchaseToStock.invalid", systemImage: MySymbols.amount)
                if quFactorPurchaseToStock != 1 {
#if os(macOS)
                    Text(LocalizedStringKey("str.md.product.quFactorPurchaseToStock.description \(currentQUPurchase?.name ?? "QU ERROR") \(String(format: "%.f", quFactorPurchaseToStock)) \(currentQUStock?.namePlural ?? "QU ERROR")"))
                        .frame(maxWidth: 200)
#else
                    Text(LocalizedStringKey("str.md.product.quFactorPurchaseToStock.description \(currentQUPurchase?.name ?? "QU ERROR") \(String(format: "%.f", quFactorPurchaseToStock)) \(currentQUStock?.namePlural ?? "QU ERROR")"))
#endif
                }
            }
            
            // Tare weight
            Group {
                MyToggle(isOn: $enableTareWeightHandling, description: "str.md.product.enableTareWeightHandling", descriptionInfo: "str.md.product.enableTareWeightHandling.info", icon: MySymbols.tareWeight)
                
                if enableTareWeightHandling {
                    MyDoubleStepper(amount: $tareWeight, description: "str.md.product.tareWeight", minAmount: 0, amountStep: 1, amountName: currentQUStock?.name ?? "QU", errorMessage: "str.md.product.tareWeight.invalid", systemImage: MySymbols.tareWeight)
                }
            }
            
            // Check stock fulfillment for recipes
            MyToggle(isOn: $notCheckStockFulfillmentForRecipes, description: "str.md.product.notCheckStockFulfillmentForRecipes", descriptionInfo: "str.md.product.notCheckStockFulfillmentForRecipes.info", icon: MySymbols.recipe)
        }
        .navigationTitle(LocalizedStringKey("str.md.product.category.amount"))
    }
    var barcodePropertiesView: some View {
        Group{
            if let product = product {
#if os(macOS)
                ScrollView{
                    MDBarcodesView(productID: product.id, toastType: $toastType)
                }
#else
                MDBarcodesView(productID: product.id, toastType: $toastType)
#endif
            }
        }
    }
}

struct MDProductFormView_Previews: PreviewProvider {
    static var previews: some View {
#if os(macOS)
        Group {
            MDProductFormView(isNewProduct: true, showAddProduct: Binding.constant(true), toastType: Binding.constant(nil))
        }
#else
        Group {
            MDProductFormView(isNewProduct: true, showAddProduct: Binding.constant(true), toastType: Binding.constant(nil))
        }
#endif
    }
}
