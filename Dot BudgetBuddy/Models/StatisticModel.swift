//
//  StatisticModel.swift
//  Dot BudgetBuddy
//
//  Created by snow on 12/21/23.
//

import Foundation
import SwiftData

struct StatisticModel {
    private var modelContext: ModelContext
    private var payments: [Payment]
    
    init(modelContainer: ModelContainer) {
        do {
            modelContext = ModelContext(modelContainer)
            payments = try modelContext.fetch(FetchDescriptor(sortBy: [SortDescriptor(\Payment.date, order: .reverse)]))
        } catch {
            fatalError("Could not initialize the payment model.")
        }
    }
    
    // calculate sum of transactions of different categories
    func transactionSum(category: String) -> Double {
        let thisMonth = Calendar.current.dateComponents([.year, .month], from: Date())
        return payments.reduce(0.0) { sum, payment in
            let paymentDateComponents = Calendar.current.dateComponents([.year, .month], from: payment.date)
            if payment.category == category && paymentDateComponents == thisMonth {
                return sum + payment.expense
            } else {
                return sum
            }
        }
    }

    func getAverageExpenseOfLast30Days() -> Double {
        let paymentsWithin90Days = payments.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date() }
        return paymentsWithin90Days.reduce(0.0) { sum, payment in
            if payment.transactionType == .expense {
                return sum + payment.expense
            } else {
                return sum
            }
        }
    }
    
    // get the category of the most expensive cost of this month
    func getMostExpensiveCategoryMonthly(selectedMonth: DateComponents) -> String? {
        let paymentsOfThatMonth = payments.filter { Calendar.current.dateComponents([.year, .month], from: $0.date) == selectedMonth && $0.transactionType == .expense}
        var categoryExpense: [String: Double] = [:]
        // iterate the filtered array
        for payment in paymentsOfThatMonth {
            let category = payment.category
            categoryExpense[category, default: 0.0] += payment.expense
        }
        if let mostExpensiveCategory = categoryExpense.max(by: { $0.value < $1.value })?.key {
            return mostExpensiveCategory
        } else {
            return nil
        }
    }
    
    // get the category of the most income of this month
    func getMostIncomeCategoryMonthly(selectedMonth: DateComponents) -> String? {
        let incomeOfThatMonth = payments.filter { Calendar.current.dateComponents([.year, .month], from: $0.date) == selectedMonth && $0.transactionType == .income}
        var categoryIncome: [String: Double] = [:]
        // iterate the filtered array
        for income in incomeOfThatMonth {
            let category = income.category
            categoryIncome[category, default: 0.0] += income.expense
        }
        if let mostIncomeCategory = categoryIncome.max(by: { $0.value < $1.value })?.key {
            return mostIncomeCategory
        } else {
            return nil
        }
    }

}
