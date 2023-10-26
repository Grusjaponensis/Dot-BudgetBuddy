//
//  Dot_BudgetBuddyApp.swift
//  Dot BudgetBuddy
//
//  Created by snow on 10/26/23.
//

import SwiftUI

@main
struct Dot_BudgetBuddyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
