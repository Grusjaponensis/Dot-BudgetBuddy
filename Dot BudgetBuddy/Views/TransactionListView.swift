//
//  TransactionListView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 12/12/23.
//

import SwiftData
import SwiftUI

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    var payment: Payment
    
    var body: some View {
        let type = payment.transactionType
        HStack {
            image
            transactionDetail
            Spacer()
            Text((type == .expense ? "-" : "+") + String(format: "¥%.2f", payment.expense)).bold()
        }
        .contextMenu { Button("Delete") { modelContext.delete(payment) } }
    }
    
    var image: some View {
        let type = payment.transactionType
        let category = payment.category
        return ZStack {
            Circle()
                .fill()
                .foregroundStyle(type == .expense ? .red : .green)
                .opacity(0.7)
            Image(
                systemName: type == .expense ?
                    PaymentCategory.allCases.first { $0.rawValue == category }?.systemImage ?? "" :
                    IncomeCategory.allCases.first { $0.rawValue == category }?.systemImage ?? ""
            )
            .bold()
            .foregroundStyle(.white)
        }
        .frame(maxWidth: 50, maxHeight: 50)
    }
    
    var transactionDetail: some View {
        VStack {
            Text(payment.category)
                .font(.system(size: 15, design: .rounded))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(payment.date.formatted(date: .omitted, time: .shortened))
                .font(.subheadline)
                .opacity(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
