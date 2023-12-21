//
//  TransactionPieChartView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 12/20/23.
//

import SwiftUI
import Charts
import SwiftData

struct TransactionPieChartView: View {
    @Query private var payments: [Payment]
    
    @State private var selectedCategory: TransactionType = .expense
    
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
        Picker("Type", selection: $selectedCategory) {
            Text("Expence")
                .tag(TransactionType.expense)
            Text("Income")
                .tag(TransactionType.income)
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 350)
        Chart(selectedCategory == .expense ? dataForExpense : dataForIncome, id: \.type) { transaction in
            SectorMark(angle: .value("Type", transaction.amount),
                       innerRadius: .ratio(0.5),
                       angularInset: 1.5)
            .cornerRadius(5)
            .opacity(transaction.type == (selectedCategory == .expense ? maxPaymentCategory : maxIncomeCategory) ? 1 : 0.5)
        }
        .foregroundStyle(.orange)
    }
}

#Preview {
    TransactionPieChartView()
}
