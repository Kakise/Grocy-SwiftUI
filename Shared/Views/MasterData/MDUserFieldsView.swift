//
//  MDUserFieldsView.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 11.12.20.
//

import SwiftUI

struct MDUserFieldRowView: View {
    var userField: MDUserField
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(userField.caption)
                .font(.largeTitle)
            Text(LocalizedStringKey("str.md.userFields.rowName \(userField.name)"))
            Text(LocalizedStringKey("str.md.userFields.rowEntity \(userField.entity)"))
            Text(LocalizedStringKey("str.md.userFields.rowType \(userField.type)"))
        }
        .padding(10)
        .multilineTextAlignment(.leading)
    }
}

struct MDUserFieldsView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isSearching: Bool = false
    @State private var searchString: String = ""
    @State private var showAddUserField: Bool = false
    
    @State private var shownEditPopover: MDUserField? = nil
    
    @State private var reloadRotationDeg: Double = 0
    
    @State private var userFieldToDelete: MDUserField? = nil
    @State private var showDeleteAlert: Bool = false
    
    func makeIsPresented(userField: MDUserField) -> Binding<Bool> {
        return .init(get: {
            return self.shownEditPopover?.id == userField.id
        }, set: { _ in    })
    }
    
    private var filteredUserFields: MDUserFields {
        grocyVM.mdUserFields
            .filter {
                searchString.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchString)
            }
            .sorted {
                $0.name < $1.name
            }
    }
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            userFieldToDelete = filteredUserFields[offset]
            showDeleteAlert.toggle()
        }
    }
    private func deleteUserField(toDelID: String) {
        grocyVM.deleteMDObject(object: .userfields, id: toDelID)
        updateData()
    }
    
    private func updateData() {
        grocyVM.getMDUserFields()
    }
    
    var body: some View {
        #if os(macOS)
        NavigationView{
            content
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        HStack{
                            if isSearching { SearchBar(text: $searchString, placeholder: "str.md.search".localized) }
                            Button(action: {
                                isSearching.toggle()
                            }, label: {Image(systemName: "magnifyingglass")})
                            Button(action: {
                                withAnimation {
                                    self.reloadRotationDeg += 360
                                }
                                updateData()
                            }, label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .rotationEffect(Angle.degrees(reloadRotationDeg))
                            })
                            Button(action: {
                                showAddUserField.toggle()
                            }, label: {Image(systemName: "plus")})
//                            .popover(isPresented: self.$showAddUserField, content: {
//                                MDShoppingLocationFormView(isNewShoppingLocation: true)
//                                    .padding()
//                                    .frame(maxWidth: 300, maxHeight: 250)
//                            })
                        }
                    }
                }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        #elseif os(iOS)
        content
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack{
                        Button(action: {
                            isSearching.toggle()
                        }, label: {Image(systemName: "magnifyingglass")})
                        Button(action: {
                            updateData()
                        }, label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        })
                        Button(action: {
                            showAddShoppingLocation.toggle()
                        }, label: {Image(systemName: "plus")})
                        .sheet(isPresented: self.$showAddShoppingLocation, content: {
                                NavigationView {
                                    MDShoppingLocationFormView(isNewShoppingLocation: true)
                                } })
                    }
                }
            }
        #endif
    }
    
    var content: some View {
        List(){
            #if os(iOS)
            if isSearching { SearchBar(text: $searchString, placeholder: "str.md.search") }
            #endif
            if grocyVM.mdUserFields.isEmpty {
                Text("str.md.empty \("str.md.userFields".localized)")
            } else if filteredUserFields.isEmpty {
                Text("str.noSearchResult")
            }
            #if os(macOS)
            ForEach(filteredUserFields, id:\.id) { userField in
//                NavigationLink(destination: MDShoppingLocationFormView(isNewShoppingLocation: false, shoppingLocation: shoppingLocation)) {
                    MDUserFieldRowView(userField: userField)
//                        .padding()
//                }
            }
            .onDelete(perform: delete)
            #else
            ForEach(filteredShoppingLocations, id:\.id) { shoppingLocation in
                NavigationLink(destination: MDShoppingLocationFormView(isNewShoppingLocation: false, shoppingLocation: shoppingLocation)) {
                    MDShoppingLocationRowView(shoppingLocation: shoppingLocation)
                }
            }
            .onDelete(perform: delete)
            #endif
        }
        .animation(.default)
        .navigationTitle("str.md.userFields".localized)
        .onAppear(perform: {
            updateData()
        })
        .alert(isPresented: $showDeleteAlert) {
            Alert(title: Text("str.md.userFields.delete.confirm"), message: Text(userFieldToDelete?.name ?? "error"), primaryButton: .destructive(Text("str.delete")) {
                deleteUserField(toDelID: userFieldToDelete?.id ?? "")
            }, secondaryButton: .cancel())
        }
    }
}

struct MDUserFieldsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            MDUserFieldRowView(shoppingLocation: MDShoppingLocation(id: "0", name: "Location", mdShoppingLocationDescription: "Description", rowCreatedTimestamp: "", userfields: nil))
            #if os(macOS)
            MDUserFieldsView()
            #else
            NavigationView() {
                MDUserFieldsView()
            }
            #endif
        }
    }
}
