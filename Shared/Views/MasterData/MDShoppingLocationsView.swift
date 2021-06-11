//
//  MDShoppingLocationsView.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 17.11.20.
//

import SwiftUI
import URLImage

struct MDShoppingLocationRowView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    var shoppingLocation: MDShoppingLocation
    
    var body: some View {
        HStack{
            if let uf = shoppingLocation.userfields?.first(where: {$0.key == AppSpecificUserFields.storeLogo.rawValue }), let pictureURL = grocyVM.getPictureURL(groupName: "userfiles", fileName: uf.value), let url = URL(string: pictureURL) {
                AsyncImage(url: url, content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(Color.white)
                }, placeholder: {
                    Color.primary
                })
                    .frame(width: 100, height: 100)
            }
            VStack(alignment: .leading) {
                Text(shoppingLocation.name)
                    .font(.largeTitle)
                if let description = shoppingLocation.mdShoppingLocationDescription, !description.isEmpty {
                    Text(shoppingLocation.mdShoppingLocationDescription!)
                        .font(.caption)
                }
            }
            .padding(10)
            .multilineTextAlignment(.leading)
        }
    }
}

struct MDShoppingLocationsView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @State private var searchString: String = ""
    @State private var showAddShoppingLocation: Bool = false
    
    @State private var shoppingLocationToDelete: MDShoppingLocation? = nil
    @State private var showDeleteAlert: Bool = false
    
    @State private var toastType: MDToastType?
    
    private var filteredShoppingLocations: MDShoppingLocations {
        grocyVM.mdShoppingLocations
            .filter {
                searchString.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchString)
            }
            .sorted {
                $0.name < $1.name
            }
    }
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            shoppingLocationToDelete = filteredShoppingLocations[offset]
            showDeleteAlert.toggle()
        }
    }
    private func deleteShoppingLocation(toDelID: String) {
        grocyVM.deleteMDObject(object: .shopping_locations, id: toDelID, completion: { result in
            switch result {
            case let .success(message):
                grocyVM.postLog(message: "Shopping location delete successful. \(message)", type: .info)
                updateData()
            case let .failure(error):
                grocyVM.postLog(message: "Shopping location delete failed. \(error)", type: .error)
                toastType = .failDelete
            }
        })
    }
    
    private func updateData() {
        grocyVM.requestData(objects: [.shopping_locations])
    }
    
    var body: some View {
        if grocyVM.failedToLoadObjects.count == 0 && grocyVM.failedToLoadAdditionalObjects.count == 0 {
            bodyContent
        } else {
            ServerOfflineView()
                .navigationTitle(LocalizedStringKey("str.md.shoppingLocations"))
        }
    }
    
#if os(macOS)
    var bodyContent: some View {
        NavigationView{
            content
                .toolbar(content: {
                    ToolbarItem(placement: .primaryAction, content: {
                        Button(action: {
                            showAddShoppingLocation.toggle()
                        }, label: {Image(systemName: MySymbols.new)})
                    })
                })
                .frame(minWidth: Constants.macOSNavWidth)
        }
        .navigationTitle(LocalizedStringKey("str.md.shoppingLocations"))
    }
#elseif os(iOS)
    var bodyContent: some View {
        content
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showAddShoppingLocation.toggle()
                    }, label: {Image(systemName: MySymbols.new)})
                }
            }
            .navigationTitle(LocalizedStringKey("str.md.shoppingLocations"))
            .sheet(isPresented: self.$showAddShoppingLocation, content: {
                NavigationView {
                    MDShoppingLocationFormView(isNewShoppingLocation: true, showAddShoppingLocation: $showAddShoppingLocation, toastType: $toastType)
                }
            })
    }
#endif
    
    var content: some View {
        List(){
            if grocyVM.mdShoppingLocations.isEmpty {
                Text(LocalizedStringKey("str.md.shoppingLocations.empty"))
            } else if filteredShoppingLocations.isEmpty {
                Text(LocalizedStringKey("str.noSearchResult"))
            }
#if os(macOS)
            if showAddShoppingLocation {
                NavigationLink(destination: MDShoppingLocationFormView(isNewShoppingLocation: true, showAddShoppingLocation: $showAddShoppingLocation, toastType: $toastType), isActive: $showAddShoppingLocation, label: {
                    NewMDRowLabel(title: "str.md.shoppingLocation.new")
                })
            }
#endif
            ForEach(filteredShoppingLocations, id:\.id) { shoppingLocation in
                NavigationLink(destination: MDShoppingLocationFormView(isNewShoppingLocation: false, shoppingLocation: shoppingLocation, showAddShoppingLocation: Binding.constant(false), toastType: $toastType)) {
                    MDShoppingLocationRowView(shoppingLocation: shoppingLocation)
                }
            }
            .onDelete(perform: delete)
        }
        .onAppear(perform: {
            grocyVM.requestData(objects: [.shopping_locations], ignoreCached: false)
        })
        .searchable(LocalizedStringKey("str.search"), text: $searchString)
        .refreshable(action: updateData)
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
        .alert(LocalizedStringKey("str.md.shoppingLocation.delete.confirm"), isPresented: $showDeleteAlert, actions: {
            Button(LocalizedStringKey("str.cancel"), role: .cancel) { }
            Button(LocalizedStringKey("str.delete"), role: .destructive) {
                deleteShoppingLocation(toDelID: shoppingLocationToDelete?.id ?? "")
            }
        }, message: { Text(shoppingLocationToDelete?.name ?? "error") })
    }
}

struct MDShoppingLocationsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MDShoppingLocationRowView(shoppingLocation: MDShoppingLocation(id: "0", name: "Location", mdShoppingLocationDescription: "Description", rowCreatedTimestamp: "", userfields: nil))
#if os(macOS)
            MDShoppingLocationsView()
#else
            NavigationView() {
                MDShoppingLocationsView()
            }
#endif
        }
    }
}
