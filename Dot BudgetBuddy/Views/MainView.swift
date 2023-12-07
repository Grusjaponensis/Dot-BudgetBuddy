//
//  ContentView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 10/26/23.
//

import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) var context
    @State private var selection = TabType.home
    @State private var isAddViewPresent = false
    @State private var isTabBarPresent = true

    var body: some View {
        VStack {
            TabView(selection: $selection) {
                HomeView(isTabBarPresented: $isTabBarPresent)
                    .tag(TabType.home)
                    .toolbar(.hidden, for: .tabBar)
                SettingsView()
                    .tag(TabType.settings)
                    .toolbar(.hidden, for: .tabBar)
            }
            MainTabView(selection: $selection, isAddViewPresent: $isAddViewPresent)
                .opacity(isTabBarPresent ? 1 : 0)
        }
        .ignoresSafeArea(.all, edges: [.bottom])
    }
}

#Preview {
    MainView()
}
