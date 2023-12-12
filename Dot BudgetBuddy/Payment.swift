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
class Payment {
    var transactionType: TransactionType
    var category: String
    var date: Date
    var expense: Double
    var notes: String?

    init(transactionType: TransactionType = .expense, category: String = "", date: Date = .now, expense: Double = 0, description: String = "") {
        self.transactionType = transactionType
        self.category = category
        self.date = date
        self.expense = expense
        self.notes = description
    }
}

var expenceImages = ["takeoutbag.and.cup.and.straw", "car", "gamecontroller", "handbag", "calendar", "figure.run"]
var incomeImages = ["dollarsign", "graduationcap", "medal", "wallet.pass", "creditcard", "gift"]

func calculateAverageSpent(_ totalCost: Double) -> Double {
    let calender = Calendar.current
    return totalCost == 0 ? 0.0 : (totalCost / Double(calender.component(.month, from: Date())))
}

func formatNumber(_ number: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: number)) ?? "0.00"
}

func transformDate(_ year: Int = Calendar.current.component(.year, from: Date()),
                   _ month: Int = Calendar.current.component(.month, from: Date()),
                   _ day: Int = Calendar.current.component(.day, from: Date())) -> Date
{
    let date = DateComponents(year: year, month: month, day: day)
    return Calendar.current.date(from: date) ?? Date()
}

func addSampleData(modelContext: ModelContext) {
    let sample1 = Payment(category: PaymentCategory.foodAndDrink.rawValue, date: transformDate(2023, 11, 30), expense: 21)
    let sample2 = Payment(category: PaymentCategory.entertainment.rawValue, date: transformDate(2023, 11, 5), expense: 648)
    let sample3 = Payment(category: PaymentCategory.sports.rawValue, date: transformDate(2023, 9, 27), expense: 25)

    modelContext.insert(sample1)
    modelContext.insert(sample2)
    modelContext.insert(sample3)
}
