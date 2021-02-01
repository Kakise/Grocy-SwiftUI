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
            if let uf = location.userfields?.first(where: {$0.key == AppSpecificUserFields.locationPicture.rawValue }) {
                if let pictureURL = grocyVM.getPictureURL(groupName: "userfiles", fileName: uf.value) {
                    if let url = URL(string: pictureURL) {
                        URLImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .background(Color.white)
                        }
                        .frame(width: 100, height: 100)
                    }
                }
            }
            VStack(alignment: .leading) {
                HStack{
                    Text(location.name)
                        .font(.largeTitle)
                    if Bool(location.isFreezer) ?? false {
                        Image(systemName: "thermometer.snowflake")
                            .font(.title)
                    }
                }
                if location.mdLocationDescription != nil {
                    if !location.mdLocationDescription!.isEmpty {
                        Text(location.mdLocationDescription!)
                            .font(.caption)
                    }
                }
            }
            .padding(10)
            .multilineTextAlignment(.leading)
        }
    }
}

struct MDLocationsView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isSearching: Bool = false
    @State private var searchString: String = ""
    @State private var showAddLocation: Bool = false
    
    @State private var shownEditPopover: MDLocation? = nil
    
    @State private var reloadRotationDeg: Double = 0
    
    @State private var locationToDelete: MDLocation? = nil
    @State private var showDeleteAlert: Bool = false
    
    @State private var toastType: MDToastType?
    
    private func updateData() {
        grocyVM.getMDLocations()
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
        grocyVM.deleteMDObject(object: .locations, id: toDelID)
        updateData()
    }
    
    var body: some View {
        #if os(macOS)
        NavigationView{
            content
                .toolbar(content: {
                    ToolbarItem(placement: .primaryAction) {
                        HStack{
                            if isSearching { SearchBarSwiftUI(text: $searchString, placeholder: "str.md.search") }
                            Button(action: {
                                isSearching.toggle()
                            }, label: {Image(systemName: "magnifyingglass")})
                            Button(action: {
                                withAnimation {
                                    self.reloadRotationDeg += 360
                                }
                                grocyVM.getMDLocations()
                            }, label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .rotationEffect(Angle.degrees(reloadRotationDeg))
                            })
                            Button(action: {
                                showAddLocation.toggle()
                            }, label: {Image(systemName: "plus")})
                            .popover(isPresented: self.$showAddLocation, content: {
                                MDLocationFormView(isNewLocation: true, toastType: $toastType)
                                    .padding()
                                    .frame(maxWidth: 300, maxHeight: 250)
                            })
                        }
                    }
                })
                .frame(minWidth: Constants.macOSNavWidth)
        }
        .navigationTitle(LocalizedStringKey("str.md.locations"))
        #elseif os(iOS)
        content
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    HStack{
                        Button(action: {
                            isSearching.toggle()
                        }, label: {Image(systemName: "magnifyingglass")})
                        Button(action: {
                            withAnimation {
                                self.reloadRotationDeg += 360
                            }
                            grocyVM.getMDLocations()
                        }, label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .rotationEffect(Angle.degrees(reloadRotationDeg))
                        })
                        Button(action: {
                            showAddLocation.toggle()
                        }, label: {Image(systemName: "plus")})
                    }
                }
            })
            .navigationTitle(LocalizedStringKey("str.md.locations"))
            .sheet(isPresented: self.$showAddLocation, content: {
                    NavigationView {
                        MDLocationFormView(isNewLocation: true, toastType: $toastType)
                    } })
        #endif
    }
    
    var content: some View {
        List(){
            #if os(iOS)
            if isSearching { SearchBar(text: $searchString, placeholder: "str.md.search") }
            #endif
            if grocyVM.mdLocations.isEmpty {
                Text(LocalizedStringKey("str.md.locations.empty"))
            } else if filteredLocations.isEmpty {
                Text(LocalizedStringKey("str.noSearchResult"))
            }
            ForEach(filteredLocations, id:\.id) {location in
                NavigationLink(destination: MDLocationFormView(isNewLocation: false, location: location, toastType: $toastType)) {
                    MDLocationRowView(location: location)
                }
            }
            .onDelete(perform: delete)
        }
        .onAppear(perform: updateData)
        .animation(.default)
        .toast(item: $toastType, isSuccess: Binding.constant(toastType == .successAdd || toastType == .successEdit), content: { item in
            switch item {
            case .successAdd:
                Label(LocalizedStringKey("str.md.new.success"), systemImage: "checkmark")
            case .failAdd:
                Label(LocalizedStringKey("str.md.new.fail"), systemImage: "xmark")
            case .successEdit:
                Label(LocalizedStringKey("str.md.edit.success"), systemImage: "checkmark")
            case .failEdit:
                Label(LocalizedStringKey("str.md.edit.fail"), systemImage: "xmark")
            }
        })
        .alert(isPresented: $showDeleteAlert) {
            Alert(title: Text("str.md.location.delete.confirm"), message: Text(locationToDelete?.name ?? "error"), primaryButton: .destructive(Text("str.delete")) {
                deleteLocation(toDelID: locationToDelete?.id ?? "")
            }, secondaryButton: .cancel())
        }
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
