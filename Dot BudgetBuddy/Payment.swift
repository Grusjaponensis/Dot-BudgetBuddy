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

    var systemImage: String {
        switch self {
        case .foodAndDrink:
            return "takeoutbag.and.cup.and.straw"
        case .transportation:
            return "car"
        case .entertainment:
            return "gamecontroller"
        case .shopping:
            return "handbag"
        case .subscriptions:
            return "calendar"
        case .sports:
            return "figure.run"
        }
    }
}

enum TransactionType: Codable {
    case income
    case expense
}

enum IncomeCategory: String, CaseIterable {
    case allowance = "Allowance"
    case scholarship = "Scholarship"
    case contestPrize = "Contest Prize"
    case pocketMoney = "Pocket Money"
    case partTimeJob = "Salary"
    case gift = "Gifts"

    var systemImage: String {
        switch self {
        case .allowance:
            return "dollarsign"
        case .scholarship:
            return "graduationcap"
        case .contestPrize:
            return "medal"
        case .pocketMoney:
            return "wallet.pass"
        case .partTimeJob:
            return "creditcard"
        case .gift:
            return "gift"
        }
    }
}

// MARK: - preserved model

@Model
class Payment: Identifiable, Equatable {
    var transactionType: TransactionType
    var category: String
    var date: Date
    var expense: Double
    var notes: String

    init(transactionType: TransactionType = .expense, category: String = "", date: Date = .now, expense: Double = 0, description: String = "") {
        self.transactionType = transactionType
        self.category = category
        self.date = date
        self.expense = expense
        self.notes = description
    }
}
