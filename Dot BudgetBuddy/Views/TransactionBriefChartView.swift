//
//  TransactionBriefChartView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 12/27/23.
//

import SwiftUI
import SwiftData
import Charts

struct TransactionBriefChartView: View {
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
    
    var dataForIncome: [(type: String, amount: Double)] {
        return IncomeCategory.allCases.map { category in
            let income = transactionSum(category: category.rawValue)
            return (category.rawValue, income)
        }
    }
    
    var maxPaymentCategory: String? {
        dataForExpense.max { $0.amount < $1.amount }?.type
    }
    
    var maxIncomeCategory: String? {
        dataForIncome.max { $0.amount < $1.amount }?.type
    }

    var body: some View {
        NavigationStack {
//            List {
                Section {
                    NavigationLink { ExpenseChartView() } label: {
                        expenseBriefView
                    }
                }
                Section {
                    NavigationLink { IncomeChartView() } label: {
                        incomeBriefView
                    }
                }
//            }
//            .scrollContentBackground(.hidden)
//            .background(.ultraThinMaterial, in:
//                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
//            )
//            .frame(maxWidth: 370)
        }
    }
    
    var expenseBriefView: some View {
        HStack {
            HStack {
                if let mostExpensiveCategory = getMostExpensiveCategoryMonthly(selectedMonth: thisMonth) {
                    Text("The most expensive category of this month is ")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    +
                    Text(mostExpensiveCategory)
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .foregroundStyle(.blue)
                }
            }
            .frame(maxWidth: 250)
            Spacer()
            Chart(dataForExpense, id: \.type) { payment in
                SectorMark(
                    angle: .value("Amount", payment.amount),
                    innerRadius: 0.618,
                    angularInset: 1.5
                )
                .cornerRadius(5.0)
                .opacity(maxPaymentCategory == payment.type ? 1 : 0.5)
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(height: 75)
            .foregroundStyle(.linearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
            Image(systemName: "chevron.right")
                .opacity(0.35)
        }
        .frame(maxWidth: 350, minHeight: 70)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial, in:
            RoundedRectangle(cornerRadius: 15.0, style: .continuous)
        )
        .tint(.primary)
    }
    
    var incomeBriefView: some View {
        HStack {
            HStack {
                if let mostIncomeCategory = getMostIncomeCategoryMonthly(selectedMonth: thisMonth) {
                    Text("The most income category of this month is ")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    +
                    Text(mostIncomeCategory)
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .foregroundStyle(.orange)
                }
            }
            .frame(maxWidth: 250)
            Spacer()
            Chart(dataForIncome, id: \.type) { income in
                SectorMark(
                    angle: .value("Amount", income.amount),
                    innerRadius: 0.618,
                    angularInset: 1.5
                )
                .cornerRadius(5.0)
                .opacity(maxIncomeCategory == income.type ? 1 : 0.5)
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(height: 75)
            .foregroundStyle(.linearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing))
            Image(systemName: "chevron.right")
                .opacity(0.35)
        }
        .frame(maxWidth: 350, minHeight: 70)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial, in:
            RoundedRectangle(cornerRadius: 15.0, style: .continuous)
        )
        .tint(.primary)
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
}
