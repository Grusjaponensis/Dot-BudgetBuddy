//
//  Dot_BudgetBuddyApp.swift
//  Dot BudgetBuddy
//
//  Created by snow on 10/26/23.
//

import SwiftUI
import SwiftData

@main
struct Dot_BudgetBuddyApp: App {
    @StateObject private var userData = UserData()
    let modelContainner: ModelContainer
    
    init() {
        do {
            modelContainner = try ModelContainer(for: Payment.self)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView(userData: userData)
        }
        .modelContainer(modelContainner)
    }
}
