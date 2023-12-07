//
//  Payment.swift
//  Dot BudgetBuddy
//
//  Created by snow on 11/29/23.
//

import Foundation
import SwiftData

enum PaymentCategory: String, CaseIterable {
    case foodAndDrink = "Food & Drink"
    case transportation = "Transportation"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case subscriptions = "Subscriptions"
    case sports = "Sports"
}

@Model
class Payment {
    var category: String
    var date: Date
    var expense: Double
    var notes: String?
    
    init(category: String = "", date: Date = .now, expense: Double = 0, description: String = "") {
        self.category = category
        self.date = date
        self.expense = expense
        self.notes = description
    }
}

func addSampleData(modelContext: ModelContext) {
    let sample1 = Payment(category: PaymentCategory.foodAndDrink.rawValue, date: transformDate(2023, 11, 30), expense: 21)
    let sample2 = Payment(category: PaymentCategory.entertainment.rawValue, date: transformDate(2023, 11, 5), expense: 648)
    let sample3 = Payment(category: PaymentCategory.sports.rawValue, date: transformDate(2023, 9, 27), expense: 25)
    
    modelContext.insert(sample1)
    modelContext.insert(sample2)
    modelContext.insert(sample3)
}
