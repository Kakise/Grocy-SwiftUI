//
//  MDUserEntitiesView.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 14.12.20.
//

import SwiftUI

struct MDUserEntityRowView: View {
    var userEntity: MDUserEntity
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(userEntity.caption)
                .font(.largeTitle)
            Text(userEntity.name)
        }
        .padding(10)
        .multilineTextAlignment(.leading)
    }
}

struct MDUserEntitiesView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @Environment(\.dismiss) var dismiss

    @State private var searchString: String = ""
    @State private var showAddUserEntity: Bool = false
    
    @State private var shownEditPopover: MDUserEntity? = nil
    
    @State private var userEntityToDelete: MDUserEntity? = nil
    @State private var showDeleteAlert: Bool = false
    
    @State private var toastType: MDToastType?
    
    private var filteredUserEntities: MDUserEntities {
        grocyVM.mdUserEntities
            .filter {
                searchString.isEmpty ? true : ($0.name.localizedCaseInsensitiveContains(searchString) || $0.caption.localizedCaseInsensitiveContains(searchString))
            }
            .sorted {
                $0.name < $1.name
            }
    }
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            userEntityToDelete = filteredUserEntities[offset]
            showDeleteAlert.toggle()
        }
    }
    
    private func deleteUserEntity(toDelID: String) {
        grocyVM.deleteMDObject(object: .userentities, id: toDelID, completion: { result in
            switch result {
            case let .success(message):
                grocyVM.postLog(message: "User entity delete successful. \(message)", type: .info)
                updateData()
            case let .failure(error):
                grocyVM.postLog(message: "User entity delete failed. \(error)", type: .error)
                toastType = .failDelete
            }
        })
    }
    
    private func updateData() {
        grocyVM.requestData(objects: [.userentities])
    }
    
    var body: some View {
        if grocyVM.failedToLoadObjects.count == 0 && grocyVM.failedToLoadAdditionalObjects.count == 0 {
            bodyContent
        } else {
            ServerOfflineView()
                .navigationTitle(LocalizedStringKey("str.md.userEntities"))
        }
    }
    
    #if os(macOS)
    var bodyContent: some View {
        NavigationView{
            content
                .toolbar(content: {
                    ToolbarItem(placement: .primaryAction, content: {
                            Button(action: {
                                showAddUserEntity.toggle()
                            }, label: {Image(systemName: MySymbols.new)})
                    })
                })
                .frame(minWidth: Constants.macOSNavWidth)
        }
        .navigationTitle(LocalizedStringKey("str.md.userEntities"))
    }
    #elseif os(iOS)
    var bodyContent: some View {
        content
            .toolbar {
                ToolbarItem(placement: .primaryAction, content: {
                        Button(action: {
                            showAddUserEntity.toggle()
                        }, label: {Image(systemName: MySymbols.new)})
                })
            }
            .navigationTitle(LocalizedStringKey("str.md.userEntities"))
            .sheet(isPresented: self.$showAddUserEntity, content: {
                    NavigationView {
                        MDUserEntityFormView(isNewUserEntity: true, showAddUserEntity: $showAddUserEntity, toastType: $toastType)
                    }
            })
    }
    #endif
    
    var content: some View {
        List(){
            if grocyVM.mdUserEntities.isEmpty {
                Text(LocalizedStringKey("str.md.userEntities.empty"))
            } else if filteredUserEntities.isEmpty {
                Text(LocalizedStringKey("str.noSearchResult"))
            }
            #if os(macOS)
            if showAddUserEntity {
                NavigationLink(destination: MDUserEntityFormView(isNewUserEntity: true, showAddUserEntity: $showAddUserEntity, toastType: $toastType), isActive: $showAddUserEntity, label: {
                    NewMDRowLabel(title: "str.md.userEntity.new")
                })
            }
            #endif
            ForEach(filteredUserEntities, id:\.id) { userEntity in
                NavigationLink(destination: MDUserEntityFormView(isNewUserEntity: false, userEntity: userEntity, showAddUserEntity: Binding.constant(false), toastType: $toastType)) {
                    MDUserEntityRowView(userEntity: userEntity)
                }
            }
            .onDelete(perform: delete)
        }
        .onAppear(perform: {
            grocyVM.requestData(objects: [.userentities], ignoreCached: false)
        })
        .searchable(LocalizedStringKey("str.search"), text: $searchString)
        .refreshable(action: updateData)
        .animation(.default, value: filteredUserEntities.count)
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
        .alert(LocalizedStringKey("str.md.userEntity.delete.confirm"), isPresented: $showDeleteAlert, actions: {
            Button(LocalizedStringKey("str.cancel"), role: .cancel) { }
            Button(LocalizedStringKey("str.delete"), role: .destructive) {
                deleteUserEntity(toDelID: userEntityToDelete?.id ?? "")
            }
        }, message: { Text(userEntityToDelete?.name ?? "error") })
    }
}

struct MDUserEntitiesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            #if os(macOS)
            MDUserEntitiesView()
            #else
            NavigationView() {
                MDUserEntitiesView()
            }
            #endif
        }
    }
}
