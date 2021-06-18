//
//  MDTaskCategoriesView.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 17.11.20.
//

import SwiftUI

struct MDTaskCategoryRowView: View {
    var taskCategory: MDTaskCategory
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(taskCategory.name)
                .font(.largeTitle)
            if let description = taskCategory.mdTaskCategoryDescription, !description.isEmpty {
                Text(description)
                    .font(.caption)
            }
        }
        .padding(10)
        .multilineTextAlignment(.leading)
    }
}

struct MDTaskCategoriesView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @Environment(\.dismiss) var dismiss

    @State private var searchString: String = ""
    @State private var showAddTaskCategory: Bool = false
    
    @State private var shownEditPopover: MDTaskCategory? = nil
    
    @State private var taskCategoryToDelete: MDTaskCategory? = nil
    @State private var showDeleteAlert: Bool = false
    
    @State private var toastType: MDToastType?
    
    private func updateData() {
        grocyVM.requestData(objects: [.task_categories])
    }
    
    private var filteredTaskCategories: MDTaskCategories {
        grocyVM.mdTaskCategories
            .filter {
                searchString.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchString)
            }
            .sorted {
                $0.name < $1.name
            }
    }
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            taskCategoryToDelete = filteredTaskCategories[offset]
            showDeleteAlert.toggle()
        }
    }
    private func deleteTaskCategory(toDelID: String) {
        grocyVM.deleteMDObject(object: .task_categories, id: toDelID, completion: { result in
            switch result {
            case let .success(message):
                grocyVM.postLog(message: "Task category delete successful. \(message)", type: .info)
                updateData()
            case let .failure(error):
                grocyVM.postLog(message: "Task category delete failed. \(error)", type: .error)
                toastType = .failDelete
            }
        })
    }
    
    var body: some View {
        if grocyVM.failedToLoadObjects.count == 0 && grocyVM.failedToLoadAdditionalObjects.count == 0 {
            bodyContent
        } else {
            ServerOfflineView()
                .navigationTitle(LocalizedStringKey("str.md.taskCategories"))
        }
    }
    
    #if os(macOS)
    var bodyContent: some View {
        NavigationView {
            content
                .toolbar(content: {
                    ToolbarItem(placement: .primaryAction, content: {
                        HStack{
                            Button(action: {
                                showAddTaskCategory.toggle()
                            }, label: {Image(systemName: MySymbols.new)})
//                            .popover(isPresented: self.$showAddTaskCategory, content: {
//                                MDTaskCategoryFormView(isNewTaskCategory: true, toastType: $toastType)
//                            })
                        }
                    })
                    ToolbarItem(placement: .automatic, content: {
                        ToolbarSearchField(searchTerm: $searchString)
                    })
                })
                .frame(minWidth: Constants.macOSNavWidth)
        }
        .navigationTitle(LocalizedStringKey("str.md.taskCategories"))
    }
    #elseif os(iOS)
    var bodyContent: some View {
        content
            .toolbar {
                ToolbarItem(placement: .primaryAction, content: {
                        Button(action: {
                            showAddTaskCategory.toggle()
                        }, label: {Image(systemName: MySymbols.new)})
                })
            }
            .navigationTitle(LocalizedStringKey("str.md.taskCategories"))
            .sheet(isPresented: self.$showAddTaskCategory, content: {
                    NavigationView {
                        MDTaskCategoryFormView(isNewTaskCategory: true, showAddTaskCategory: $showAddTaskCategory, toastType: $toastType)
                    }
            })
    }
    #endif
    
    var content: some View {
        List(){
            if grocyVM.mdTaskCategories.isEmpty {
                Text(LocalizedStringKey("str.md.taskCategories.empty"))
            } else if filteredTaskCategories.isEmpty {
                Text(LocalizedStringKey("str.noSearchResult"))
            }
            #if os(macOS)
            if showAddTaskCategory {
                NavigationLink(destination: MDTaskCategoryFormView(isNewTaskCategory: true, showAddTaskCategory: $showAddTaskCategory, toastType: $toastType), isActive: $showAddTaskCategory, label: {
                    NewMDRowLabel(title: "str.md.taskCategory.new")
                })
            }
            #endif
            ForEach(filteredTaskCategories, id:\.id) { taskCategory in
                NavigationLink(destination: MDTaskCategoryFormView(isNewTaskCategory: false, taskCategory: taskCategory, showAddTaskCategory: Binding.constant(false), toastType: $toastType)) {
                    MDTaskCategoryRowView(taskCategory: taskCategory)
                }
            }
            .onDelete(perform: delete)
        }
        .onAppear(perform: {
            grocyVM.requestData(objects: [.task_categories], ignoreCached: false)
        })
        .searchable(LocalizedStringKey("str.search"), text: $searchString)
        .refreshable(action: updateData)
        .animation(.default, value: filteredTaskCategories.count)
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
        .alert(LocalizedStringKey("str.md.taskCategory.delete.confirm"), isPresented: $showDeleteAlert, actions: {
            Button(LocalizedStringKey("str.cancel"), role: .cancel) { }
            Button(LocalizedStringKey("str.delete"), role: .destructive) {
                deleteTaskCategory(toDelID: taskCategoryToDelete?.id ?? "")
            }
        }, message: { Text(taskCategoryToDelete?.name ?? "error") })
    }
}

struct MDTaskCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MDTaskCategoryRowView(taskCategory: MDTaskCategory(id: "0", name: "Name", mdTaskCategoryDescription: "Description", rowCreatedTimestamp: "", userfields: nil))
            #if os(macOS)
            MDTaskCategoriesView()
            #else
            NavigationView() {
                MDTaskCategoriesView()
            }
            #endif
        }
    }
}
