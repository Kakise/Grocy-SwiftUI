//
//  MDLocationFormView.swift
//  Grocy-SwiftUI (iOS)
//
//  Created by Georg Meissner on 16.11.20.
//

import SwiftUI

struct MDLocationFormView: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var mdLocationDescription: String = ""
    @State private var isFreezer: Bool = false
    
    @State private var showFreezerInfo: Bool = false
    
    @State private var showDeleteAlert: Bool = false
    
    var isNewLocation: Bool
    var location: MDLocation?
    
    @State var isNameCorrect: Bool = false
    private func checkNameCorrect() -> Bool {
        let foundLocation = grocyVM.mdLocations.first(where: {$0.name == name})
        return isNewLocation ? !(name.isEmpty || foundLocation != nil) : !(name.isEmpty || (foundLocation != nil && foundLocation!.id != location!.id))
    }
    
    private func resetForm() {
        if isNewLocation {
            self.name = ""
            self.mdLocationDescription = ""
            self.isFreezer = false
        } else {
            self.name = location!.name
            self.mdLocationDescription = location!.mdLocationDescription ?? ""
            self.isFreezer = Bool(location!.isFreezer) ?? false
        }
        isNameCorrect = checkNameCorrect()
    }
    
    private func saveLocation() {
        if isNewLocation {
            grocyVM.postMDObject(object: .locations, content: MDLocationPOST(id: grocyVM.findNextID(.locations), name: name, mdLocationDescription: mdLocationDescription, rowCreatedTimestamp: Date().iso8601withFractionalSeconds, isFreezer: String(isFreezer), userfields: nil))
        } else {
            grocyVM.putMDObjectWithID(object: .locations, id: location!.id, content: MDLocationPOST(id: Int(location!.id)!, name: name, mdLocationDescription: mdLocationDescription, rowCreatedTimestamp: location!.rowCreatedTimestamp, isFreezer: String(isFreezer), userfields: nil))
        }
        grocyVM.getMDLocations()
    }
    
    private func deleteLocation() {
        grocyVM.deleteMDObject(object: .locations, id: location!.id)
        grocyVM.getMDLocations()
    }
    
    var body: some View {
        Form {
            Section(header: Text(LocalizedStringKey("str.md.location.info"))){
                MyTextField(textToEdit: $name, description: "str.md.location.name", isCorrect: $isNameCorrect, leadingIcon: "tag", isEditing: true, emptyMessage: "str.md.location.name.required", errorMessage: "str.md.location.name.exists")
                    .onChange(of: name, perform: { value in
                        isNameCorrect = checkNameCorrect()
                    })
                MyTextField(textToEdit: $mdLocationDescription, description: "str.md.description", isCorrect: Binding.constant(true), leadingIcon: "text.justifyleft", isEditing: true)
            }
            Section(header: Text(LocalizedStringKey("str.md.location.freezer"))){
                MyToggle(isOn: $isFreezer, description: "str.md.location.isFreezing", descriptionInfo: "str.md.location.isFreezing.description", icon: "thermometer.snowflake")
            }
            #if os(macOS)
            HStack{
                Button(LocalizedStringKey("str.cancel")) {
                    if isNewLocation{
                        NSApp.sendAction(#selector(NSPopover.performClose(_:)), to: nil, from: nil)
                    } else {
                        resetForm()
                    }
                }
                .keyboardShortcut(.cancelAction)
                Spacer()
                Button(LocalizedStringKey("str.save")) {
                    saveLocation()
                    NSApp.sendAction(#selector(NSPopover.performClose(_:)), to: nil, from: nil)
                }
                .keyboardShortcut(.defaultAction)
            }
            #endif
            if !isNewLocation {
                Button(action: {
                    showDeleteAlert.toggle()
                }, label: {
                    Label(LocalizedStringKey("str.md.delete \("str.md.location".localized)"), systemImage: "trash")
                        .foregroundColor(.red)
                })
                .keyboardShortcut(.delete)
                .alert(isPresented: $showDeleteAlert) {
                    Alert(title: Text(LocalizedStringKey("str.md.location.delete.confirm")), message: Text(""), primaryButton: .destructive(Text(LocalizedStringKey("str.delete"))) {
                        deleteLocation()
                        #if os(macOS)
                        NSApp.sendAction(#selector(NSPopover.performClose(_:)), to: nil, from: nil)
                        #else
                        presentationMode.wrappedValue.dismiss()
                        #endif
                    }, secondaryButton: .cancel())
                }
            }
        }
        .navigationTitle(isNewLocation ? LocalizedStringKey("str.md.location.new") : LocalizedStringKey("str.md.location.edit"))
        .animation(.default)
        .onAppear(perform: {
            resetForm()
        })
        .toolbar(content: {
            #if os(iOS)
            ToolbarItem(placement: .cancellationAction) {
                if isNewLocation {
                    Button(LocalizedStringKey("str.cancel")) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(LocalizedStringKey("str.md.save \("str.md.location".localized)")) {
                    saveLocation()
                    presentationMode.wrappedValue.dismiss()
                }.disabled(!isNameCorrect)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                // Back not shown without it
                if !isNewLocation{
                    Text("")
                }
            }
            #endif
        })
    }
}

struct MDLocationFormView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(macOS)
        Group {
            MDLocationFormView(isNewLocation: true)
            MDLocationFormView(isNewLocation: false, location: MDLocation(id: "1", name: "Loc", mdLocationDescription: "descr", rowCreatedTimestamp: "", isFreezer: "1", userfields: nil))
        }
        #else
        Group {
            NavigationView {
                MDLocationFormView(isNewLocation: true)
            }
            NavigationView {
                MDLocationFormView(isNewLocation: false, location: MDLocation(id: "1", name: "Loc", mdLocationDescription: "descr", rowCreatedTimestamp: "", isFreezer: "1", userfields: nil))
            }
        }
        #endif
    }
}
