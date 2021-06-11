//
//  ShoppingListFilterView.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 27.11.20.
//

import SwiftUI

struct ShoppingListFilterView: View {
    @Binding var filteredStatus: ShoppingListStatus
    
    var body: some View {
        Picker(selection: $filteredStatus, label: Label(LocalizedStringKey("str.shL.filter.status"), systemImage: MySymbols.filter), content: {
            Text(LocalizedStringKey(ShoppingListStatus.all.rawValue)).tag(ShoppingListStatus.all)
            Text(LocalizedStringKey(ShoppingListStatus.belowMinStock.rawValue)).tag(ShoppingListStatus.belowMinStock)
            Text(LocalizedStringKey(ShoppingListStatus.undone.rawValue)).tag(ShoppingListStatus.undone)
            
        }).pickerStyle(MenuPickerStyle())
    }
}

struct ShoppingListFilterView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListFilterView(filteredStatus: Binding.constant(ShoppingListStatus.all))
    }
}
