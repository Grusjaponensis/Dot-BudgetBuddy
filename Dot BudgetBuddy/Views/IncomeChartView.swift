//
//  IncomeChartView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 12/27/23.
//

import SwiftUI
import SwiftData
import Charts

struct IncomeChartView: View {
    @Query private var payments: [Payment]
    private let thisMonth = Calendar.current.dateComponents([.year, .month], from: Date())
    
    private func transactionSum(category: String) -> Double {
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

    var dataForIncome: [(type: String, amount: Double)] {
        return IncomeCategory.allCases.map { category in
            let income = transactionSum(category: category.rawValue)
            return (category.rawValue, income)
        }
    }
    
    var maxIncomeCategory: String? {
        dataForIncome.max { $0.amount < $1.amount }?.type
    }

    var body: some View {
        VStack {
            title
            incomeChart
            Spacer()
        }
    }
    
    var title: some View {
        Text("Income Statistics")
            .font(.system(.largeTitle, design: .rounded))
            .bold()
            .frame(maxWidth: 350, alignment: .leading)
    }
    
    var incomeChart: some View {
        Chart(dataForIncome, id: \.type) { transaction in
            SectorMark(angle: .value("Type", transaction.amount),
                       innerRadius: .ratio(0.75),
                       angularInset: 1.5)
            .cornerRadius(5)
            .foregroundStyle(by: .value("Name", transaction.type))
            .opacity(transaction.type == maxIncomeCategory ? 1 : 0.5)
        }
        .chartLegend(alignment: .center, spacing: 18)
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 330)
        .chartBackground { proxy in
            GeometryReader { geometry in
                let frame = geometry[proxy.plotFrame!]
                if let mostIncomeCategory = getMostIncomeCategoryMonthly(selectedMonth: thisMonth) {
                    VStack {
                        Text("Most Income Category is")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .opacity(0.6)
                        Text(mostIncomeCategory)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.primary)
                        HStack {
                            Text("Avr")
                                .foregroundStyle(.secondary)
                            Text("¥\(formatNumber(getAverageIncomeOfLast60Days() / 2))")
                                .bold()
                                .foregroundStyle(.primary)
                            Text("per month")
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                        .opacity(0.75)
                    }
                    .position(CGPoint(x: frame.midX, y: frame.midY))
                }
            }
        }
    }
    
    private func getMostExpensiveCategoryMonthly(selectedMonth: DateComponents) -> String? {
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
    
    private func getMostIncomeCategoryMonthly(selectedMonth: DateComponents) -> String? {
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
    
    private func getAverageIncomeOfLast60Days() -> Double {
        let paymentsWithin90Days = payments.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -60, to: Date()) ?? Date() }
        return paymentsWithin90Days.reduce(0.0) { sum, payment in
            if payment.transactionType == .income {
                return sum + payment.expense
            } else {
                return sum
            }
        }
    }
}
