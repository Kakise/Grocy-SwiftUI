//
//  LabelStyles.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 18.01.21.
//

import SwiftUI

struct IconAboveTextLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center) {
            configuration.icon
                .font(.title)
            configuration.title
                .font(.caption)
        }
    }
}
