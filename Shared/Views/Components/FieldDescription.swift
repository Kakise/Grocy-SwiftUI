//
//  FieldDescription.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 06.01.21.
//

import SwiftUI

struct FieldDescription: View {
    var description: String
    
#if os(iOS)
    @State private var showDescription: Bool = false
#endif
    
    var body: some View {
        Image(systemName: "questionmark.circle.fill")
            .help(LocalizedStringKey(description))
#if os(iOS)
            .onTapGesture {
                showDescription.toggle()
            }
            .popover(isPresented: $showDescription, content: {
                Text(LocalizedStringKey(description))
                    .padding()
            })
#endif
    }
}

struct FieldDescription_Previews: PreviewProvider {
    static var previews: some View {
        FieldDescription(description: "Description")
    }
}
