//
//  ExpenseChartView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 12/20/23.
//

import Charts
import SwiftData
import SwiftUI

struct ExpenseChartView: View {
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
    
    var dataForExpense: [(type: String, amount: Double)] {
        return PaymentCategory.allCases.map { category in
            let expence = transactionSum(category: category.rawValue)
            return (category.rawValue, expence)
        }
    }
    
    var maxPaymentCategory: String? {
        dataForExpense.max { $0.amount < $1.amount }?.type
    }
    
    var body: some View {
        VStack {
            title
            expensePieChart
            Spacer()
        }
    }
    
    var title: some View {
        Text("Expense Statistics")
            .font(.system(.largeTitle, design: .rounded))
            .bold()
            .frame(maxWidth: 350, alignment: .leading)
    }
    
    var expensePieChart: some View {
        Chart(dataForExpense, id: \.type) { transaction in
            SectorMark(angle: .value("Type", transaction.amount),
                       innerRadius: .ratio(0.75),
                       angularInset: 1.5)
                .cornerRadius(5)
                .foregroundStyle(by: .value("Name", transaction.type))
                .opacity(transaction.type == maxPaymentCategory ? 1 : 0.5)
        }
        .chartLegend(alignment: .center, spacing: 18)
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 330)
        .chartBackground { proxy in
            GeometryReader { geometry in
                let frame = geometry[proxy.plotFrame!]
                if let mostExpensiveCategory = getMostExpensiveCategoryMonthly(selectedMonth: thisMonth) {
                    VStack {
                        Text("Most Expensive Category is")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .opacity(0.75)
                        Text(mostExpensiveCategory)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.primary)
                        HStack {
                            Text("Avr")
                                .foregroundStyle(.secondary)
                            Text("¥\(formatNumber(getAverageExpenseOfLast30Days() / 30))")
                                .bold()
                                .foregroundStyle(.primary)
                            Text("last 30 days")
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
        let paymentsOfThatMonth = payments.filter { Calendar.current.dateComponents([.year, .month], from: $0.date) == selectedMonth && $0.transactionType == .expense }
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
        let incomeOfThatMonth = payments.filter { Calendar.current.dateComponents([.year, .month], from: $0.date) == selectedMonth && $0.transactionType == .income }
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
    
    private func getAverageExpenseOfLast30Days() -> Double {
        let paymentsWithin90Days = payments.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date() }
        return paymentsWithin90Days.reduce(0.0) { sum, payment in
            if payment.transactionType == .expense {
                return sum + payment.expense
            } else {
                return sum
            }
        }
    }
}

//struct ExpenseTableView: View {
//    @Query private var payments: [Payment]
//    
//    @State var scrollPosition: TimeInterval = .init()
//    private let numberOfDisplayedDays = 30
//    
//    var scrollPositionStart: Date {
//        Date(timeIntervalSinceReferenceDate: scrollPosition)
//    }
//    
//    var scrollPositionEnd: Date {
//        scrollPositionStart.addingTimeInterval(3600 * 24 * 30)
//    }
//    
//    var scrollPositionString: String {
//        scrollPositionStart.formatted(.dateTime.month().day())
//    }
//    
//    var scrollPositionEndString: String {
//        scrollPositionEnd.formatted(.dateTime.month().day().year())
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 5) {
//            Text("\(scrollPositionString) – \(scrollPositionEndString)")
//                .font(.callout)
//                .foregroundStyle(.secondary)
//            
//            Chart(payments, id: \.self) {
//                BarMark(
//                    x: .value("Day", $0.date, unit: .day),
//                    y: .value("Sales", $0.expense))
//            }
//            .chartScrollableAxes(.horizontal)
//            .chartXVisibleDomain(length: 3600 * 24 * numberOfDisplayedDays) // shows 30 days
//            .chartScrollTargetBehavior(
//                .valueAligned(
//                    matching: .init(hour: 0),
//                    majorAlignment: .matching(.init(day: 1))))
//            .chartScrollPosition(x: $scrollPosition)
//        }
//    }
//}
