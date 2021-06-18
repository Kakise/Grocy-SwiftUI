//
//  MyToggle.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 19.11.20.
//

import SwiftUI

struct MyToggle: View {
    @Binding var isOn: Bool
    var description: String
    var descriptionInfo: String?
    var icon: String?
    
    @State private var showInfo: Bool = false
    
    var body: some View {
        HStack{
            if let icon = icon {
                Toggle(isOn: $isOn, label: {
                    Label(LocalizedStringKey(description), systemImage: icon)
                        .foregroundColor(.primary)
                })
            } else {
                Toggle(LocalizedStringKey(description), isOn: $isOn)
            }
            if let descriptionInfo = descriptionInfo {
                FieldDescription(description: descriptionInfo)
            }
        }
    }
}

struct MyToggle_Previews: PreviewProvider {
    static var previews: some View {
        MyToggle(isOn: Binding.constant(true), description: "Description", descriptionInfo: "Descriptioninfo", icon: "tag")
    }
}
