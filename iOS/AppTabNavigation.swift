//
//  AppTabNavigation.swift
//  Grocy-SwiftUI (iOS)
//
//  Created by Georg Meissner on 13.11.20.
//

import SwiftUI

extension AppTabNavigation {
    private enum Tab: String {
        case quickScanMode = "barcode.viewfinder"
        case stockOverview = "books.vertical"
        case shoppingList = "cart"
        case more = "ellipsis.circle"
        case masterData = "text.book.closed"
        case activities = "play.rectangle"
        case settings = "gear"
    }
}

struct AppTabNavigation: View {
    @AppStorage("tabSelection") private var tabSelection: Tab = .stockOverview
    @AppStorage("devMode") private var devMode: Bool = false
    
    var body: some View {
        TabView(selection: $tabSelection) {
            NavigationView {
                QuickScanModeView()
            }
            .tabItem {
                Label(LocalizedStringKey("str.nav.quickScan"), systemImage: Tab.quickScanMode.rawValue)
                    .accessibility(label: Text(LocalizedStringKey("str.nav.quickScan")))
            }
            .tag(Tab.quickScanMode)
            
            NavigationView {
                StockView()
            }
            .tabItem {
                Label(LocalizedStringKey("str.nav.stockOverview"), systemImage: Tab.stockOverview.rawValue)
                    .accessibility(label: Text("str.nav.stockOverview"))
            }
            .tag(Tab.stockOverview)
            
            NavigationView {
                ShoppingListView()
            }
            .tabItem {
                Label("str.nav.shoppingList", systemImage: Tab.shoppingList.rawValue)
                    .accessibility(label: Text("str.nav.shoppingList"))
            }
            .tag(Tab.shoppingList)
            
            
//            if devMode {
//                NavigationView {
//                    ActivitiesView()
//                }
//                .tabItem {
//                    Label("str.nav.activities", systemImage: Tab.activities.rawValue)
//                        .accessibility(label: Text("str.nav.activities"))
//                }
//                .tag(Tab.activities)
//            }
            
            NavigationView {
                MasterDataView()
            }
            .tabItem {
                Label("str.nav.md", systemImage: Tab.masterData.rawValue)
                    .accessibility(label: Text("str.nav.md"))
            }
            .tag(Tab.masterData)
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("str.nav.settings", systemImage: Tab.settings.rawValue)
                    .accessibility(label: Text("str.nav.settings"))
            }
            .tag(Tab.settings)
            
//            if devMode {
//                NavigationView {
//                    OpenFoodFactsScannerView()
//                }
//                .tabItem {
//                    Label("OPEN FOOD FACTS", systemImage: Tab.quickScanMode.rawValue)
//                        .accessibility(label: Text("OPEN FOOD FACTS"))
//                }
//                .tag(Tab.quickScanMode)
//            }
            
        }
        //        Text("Hi")
    }
}

struct AppTabNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppTabNavigation()
    }
}
