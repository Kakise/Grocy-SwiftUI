//
//  MDTaskCategoryForm.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 12.03.21.
//

import SwiftUI

struct MDTaskCategoryFormView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var firstAppear: Bool = true
    @State private var isProcessing: Bool = false
    
    @State private var name: String = ""
    @State private var mdTaskCategoryDescription: String = ""
    
    var isNewTaskCategory: Bool
    var taskCategory: MDTaskCategory?
    
    @Binding var showAddTaskCategory: Bool
    @Binding var toastType: MDToastType?
    
    @State var isNameCorrect: Bool = false
    private func checkNameCorrect() -> Bool {
        let foundTaskCategory = grocyVM.mdTaskCategories.first(where: {$0.name == name})
        if isNewTaskCategory {
            return !(name.isEmpty || foundTaskCategory != nil)
        } else {
            if let taskCategory = taskCategory, let foundTaskCategory = foundTaskCategory {
                return !(name.isEmpty || (foundTaskCategory.id != taskCategory.id))
            } else { return false }
        }
    }
    
    private func resetForm() {
        self.name = taskCategory?.name ?? ""
        self.mdTaskCategoryDescription = taskCategory?.mdTaskCategoryDescription ?? ""
        isNameCorrect = checkNameCorrect()
    }
    
    private func updateData() {
        grocyVM.requestData(objects: [.task_categories])
    }
    
    private func finishForm() {
        #if os(iOS)
        presentationMode.wrappedValue.dismiss()
        #elseif os(macOS)
        if isNewTaskCategory {
            showAddTaskCategory = false
        }
        #endif
    }
    
    private func saveTaskCategory() {
        let id = isNewTaskCategory ? String(grocyVM.findNextID(.task_categories)) : taskCategory!.id
        let timeStamp = isNewTaskCategory ? Date().iso8601withFractionalSeconds : taskCategory!.rowCreatedTimestamp
        let taskCategoryPOST = MDTaskCategory(id: id, name: name, mdTaskCategoryDescription: mdTaskCategoryDescription, rowCreatedTimestamp: timeStamp, userfields: nil)
        isProcessing = true
        if isNewTaskCategory {
            grocyVM.postMDObject(object: .task_categories, content: taskCategoryPOST, completion: { result in
                switch result {
                case let .success(message):
                    grocyVM.postLog(message: "Task category add successful. \(message)", type: .info)
                    toastType = .successAdd
                    resetForm()
                    updateData()
                    finishForm()
                case let .failure(error):
                    grocyVM.postLog(message: "Task category add failed. \(error)", type: .error)
                    toastType = .failAdd
                }
                isProcessing = false
            })
        } else {
            grocyVM.putMDObjectWithID(object: .task_categories, id: id, content: taskCategoryPOST, completion: { result in
                switch result {
                case let .success(message):
                    grocyVM.postLog(message: "Task category edit successful. \(message)", type: .info)
                    toastType = .successEdit
                    updateData()
                    finishForm()
                case let .failure(error):
                    grocyVM.postLog(message: "Task category edit failed. \(error)", type: .error)
                    toastType = .failEdit
                }
                isProcessing = false
            })
        }
    }
    
    var body: some View {
        #if os(macOS)
        ScrollView {
            content
                .padding()
        }
        #elseif os(iOS)
        content
            .navigationTitle(isNewTaskCategory ? LocalizedStringKey("str.md.taskCategory.new") : LocalizedStringKey("str.md.taskCategory.edit"))
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    if isNewTaskCategory {
                        Button(LocalizedStringKey("str.cancel")) {
                            finishForm()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("str.md.taskCategory.save")) {
                        saveTaskCategory()
                    }
                    .disabled(!isNameCorrect || isProcessing)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    // Back not shown without it
                    if !isNewTaskCategory{
                        Text("")
                    }
                }
            })
        #endif
    }
    
    var content: some View {
        Form {
            Section(header: Text(LocalizedStringKey("str.md.taskCategory.info"))){
                MyTextField(textToEdit: $name, description: "str.md.taskCategory.name", isCorrect: $isNameCorrect, leadingIcon: "tag", emptyMessage: "str.md.productGroup.name.required", errorMessage: "str.md.taskCategory.name.exists")
                    .onChange(of: name, perform: { value in
                        isNameCorrect = checkNameCorrect()
                    })
                MyTextField(textToEdit: $mdTaskCategoryDescription, description: "str.md.description", isCorrect: Binding.constant(true), leadingIcon: MySymbols.description)
            }
            #if os(macOS)
            HStack{
                Button(LocalizedStringKey("str.cancel")) {
                    if isNewTaskCategory{
                        finishForm()
                    } else {
                        resetForm()
                    }
                }
                .keyboardShortcut(.cancelAction)
                Spacer()
                Button(LocalizedStringKey("str.save")) {
                    saveTaskCategory()
                }
                .disabled(!isNameCorrect || isProcessing)
                .keyboardShortcut(.defaultAction)
            }
            #endif
        }
        .onAppear(perform: {
            if firstAppear {
                grocyVM.requestData(objects: [.task_categories], ignoreCached: false)
                resetForm()
                firstAppear = false
            }
        })
    }
}

//struct MDTaskCategoryFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        #if os(macOS)
//        Group {
//            MDProductGroupFormView(isNewProductGroup: true, toastType: Binding.constant(nil))
//            MDProductGroupFormView(isNewProductGroup: false, productGroup: MDProductGroup(id: "0", name: "Name", mdProductGroupDescription: "Description", rowCreatedTimestamp: "", userfields: nil), toastType: Binding.constant(nil))
//        }
//        #else
//        Group {
//            NavigationView {
//                MDProductGroupFormView(isNewProductGroup: true, toastType: Binding.constant(nil))
//            }
//            NavigationView {
//                MDProductGroupFormView(isNewProductGroup: false, productGroup: MDProductGroup(id: "0", name: "Name", mdProductGroupDescription: "Description", rowCreatedTimestamp: "", userfields: nil), toastType: Binding.constant(nil))
//            }
//        }
//        #endif
//    }
//}

