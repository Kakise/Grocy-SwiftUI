//
//  MDLocationsView.swift
//  grocy-ios
//
//  Created by Georg Meissner on 13.10.20.
//

import SwiftUI
import URLImage

struct MDLocationRowView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    var location: MDLocation
    
    var body: some View {
        HStack{
            if let uf = location.userfields?.first(where: {$0.key == AppSpecificUserFields.locationPicture.rawValue }), let pictureURL = grocyVM.getPictureURL(groupName: "userfiles", fileName: uf.value), let url = URL(string: pictureURL) {
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
                HStack{
                    Text(location.name)
                        .font(.largeTitle)
                    if (location.isFreezer as NSString).boolValue {
                        Image(systemName: "thermometer.snowflake")
                            .font(.title)
                    }
                }
                if let description = location.mdLocationDescription, !description.isEmpty {
                    Text(location.mdLocationDescription!)
                        .font(.caption)
                }
            }
            .padding(10)
            .multilineTextAlignment(.leading)
        }
    }
}

struct MDLocationsView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @State private var searchString: String = ""
    @State private var showAddLocation: Bool = false
    
    @State private var locationToDelete: MDLocation? = nil
    @State private var showDeleteAlert: Bool = false
    
    @State private var toastType: MDToastType?
    
    private func updateData() {
        grocyVM.requestData(objects: [.locations])
    }
    
    private var filteredLocations: MDLocations {
        grocyVM.mdLocations
            .filter {
                searchString.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchString)
            }
            .sorted {
                $0.name < $1.name
            }
    }
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            locationToDelete = filteredLocations[offset]
            showDeleteAlert.toggle()
        }
    }
    private func deleteLocation(toDelID: String) {
        grocyVM.deleteMDObject(object: .locations, id: toDelID, completion: { result in
            switch result {
            case let .success(message):
                grocyVM.postLog(message: "Location delete successful. \(message)", type: .info)
                updateData()
            case let .failure(error):
                grocyVM.postLog(message: "Location delete failed. \(error)", type: .error)
                toastType = .failDelete
            }
        })
    }
    
    var body: some View {
        if grocyVM.failedToLoadObjects.count == 0 && grocyVM.failedToLoadAdditionalObjects.count == 0 {
            bodyContent
        } else {
            ServerOfflineView()
                .navigationTitle(LocalizedStringKey("str.md.locations"))
        }
    }
    
#if os(macOS)
    var bodyContent: some View {
        NavigationView{
            content
                .toolbar(content: {
                    ToolbarItem(placement: .primaryAction, content: {
                        Button(action: {
                            showAddLocation.toggle()
                        }, label: {Image(systemName: MySymbols.new)})
                    })
                })
                .frame(minWidth: Constants.macOSNavWidth)
        }
        .navigationTitle(LocalizedStringKey("str.md.locations"))
    }
#elseif os(iOS)
    var bodyContent: some View {
        content
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction, content: {
                    Button(action: {
                        showAddLocation.toggle()
                    }, label: {Image(systemName: MySymbols.new)})
                })
            })
            .navigationTitle(LocalizedStringKey("str.md.locations"))
            .sheet(isPresented: self.$showAddLocation, content: {
                NavigationView {
                    MDLocationFormView(isNewLocation: true, showAddLocation: $showAddLocation, toastType: $toastType)
                } })
    }
#endif
    
    var content: some View {
        List(){
            if grocyVM.mdLocations.isEmpty {
                Text(LocalizedStringKey("str.md.locations.empty"))
            } else if filteredLocations.isEmpty {
                Text(LocalizedStringKey("str.noSearchResult"))
            }
#if os(macOS)
            if showAddLocation {
                NavigationLink(destination: MDLocationFormView(isNewLocation: true, showAddLocation: $showAddLocation, toastType: $toastType), isActive: $showAddLocation, label: {
                    NewMDRowLabel(title: "str.md.location.new")
                })
            }
#endif
            ForEach(filteredLocations, id:\.id) {location in
                NavigationLink(destination: MDLocationFormView(isNewLocation: false, location: location, showAddLocation: Binding.constant(false), toastType: $toastType)) {
                    MDLocationRowView(location: location)
                }
            }
            .onDelete(perform: delete)
        }
        .onAppear(perform: { grocyVM.requestData(objects: [.locations], ignoreCached: false) })
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
        .alert(LocalizedStringKey("str.md.location.delete.confirm"), isPresented: $showDeleteAlert, actions: {
            Button(LocalizedStringKey("str.cancel"), role: .cancel) { }
            Button(LocalizedStringKey("str.delete"), role: .destructive) {
                deleteLocation(toDelID: locationToDelete?.id ?? "")
            }
        }, message: { Text(locationToDelete?.name ?? "error") })
    }
}

struct MDLocationsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MDLocationRowView(location: MDLocation(id: "0", name: "Location", mdLocationDescription: "Location description", rowCreatedTimestamp: "", isFreezer: "0", userfields: nil))
#if os(macOS)
            MDLocationsView()
#else
            NavigationView() {
                MDLocationsView()
            }
#endif
        }
    }
}
