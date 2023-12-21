//
//  ContentView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 10/26/23.
//

import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) var context
    
    @ObservedObject var userData: UserData
    
    @State private var selection = TabType.home
    @State private var isAddViewPresent = false

    var body: some View {
        VStack {
            TabView(selection: $selection) {
                HomeView(userData: userData)
                    .tag(TabType.home)
                    .toolbar(.hidden, for: .tabBar)
                SettingsView(userData: userData)
                    .tag(TabType.settings)
                    .toolbar(.hidden, for: .tabBar)
            }
            MainTabView(selection: $selection, isAddViewPresent: $isAddViewPresent)
        }
        .ignoresSafeArea(.all, edges: [.bottom])
    }
}

#Preview {
    MainView(userData: UserData())
}
