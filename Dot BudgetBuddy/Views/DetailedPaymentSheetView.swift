//
//  DetailedPaymentSheetView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 11/26/23.
//

import SwiftUI
import SwiftData
import Charts

struct DetailedPaymentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    
    @ObservedObject var userData: UserData
    
    @Query(sort: \Payment.date, order: .reverse) var payments: [Payment]
    
    @Binding var isPresented: Bool
    var monthlyExpense: Double
    var yearlyExpense: Double
    var monthlyEarning: Double
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                title
                totalSpent
                Divider()
                yearlySpent
                Divider()
                statistics
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button(action: { isPresented.toggle() }) {
                    Text("Done").foregroundStyle(.orange)
                }
            )
        }
    }

    // MARK: - sheet title

    var title: some View {
        Text("MONTHLY SPENDING")
            .font(.system(.subheadline, design: .rounded))
            .fontWeight(.bold)
            .opacity(0.35)
    }

    // MARK: - monthly spent

    var totalSpent: some View {
        VStack(spacing: 20) {
            Text("¥\(formatNumber(monthlyExpense))")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(colorScheme == .dark ? .orange : .primary)
            HStack {
                if monthlyExpense > userData.userBudget + monthlyEarning {
                    Text("¥\(formatNumber(monthlyExpense - monthlyEarning))")
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .opacity(0.5)
                        .frame(alignment: .trailing)
                    Text("over")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.red)
                        .bold()
                        .frame(alignment: .leading)
                } else {
                    Text("¥\(formatNumber(monthlyEarning - monthlyExpense))")
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .opacity(0.5)
                        .frame(alignment: .trailing)
                    Text("left")
                        .font(.system(.body, design: .rounded))
                        .opacity(0.5)
                        .frame(alignment: .leading)
                }
            }
            ZStack {
                Circle()
                    .stroke(.secondary.opacity(0.3), lineWidth: 20)
                Circle()
                    .trim(from: 0.0, to: getBudgetLeftPercentage())
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.red, .orange, .red]),
                            center: .center,
                            angle: .zero
                        ),
                        style: .init(lineWidth: 20, lineCap: .round, lineJoin: .round)
                    )
                    .animation(.easeInOut(duration: 1), value: getBudgetLeftPercentage())
                Text(
                    Double(String(format: "%.2f", getBudgetLeftPercentage()))!
                        .formatted(.percent)
                )
                .font(.system(.title, design: .rounded))
                .bold()
                .foregroundStyle(.orange)
            }
            .frame(maxWidth: 110, maxHeight: 150)
        }
    }

    // MARK: - yearly spent

    var yearlySpent: some View {
        VStack(spacing: 20) {
            HStack {
                Text("YEARLY METRICS")
                    .font(.system(.subheadline, design: .rounded))
                    .bold()
                    .opacity(0.35)
                    .frame(maxWidth: 300, alignment: .center)
                    .offset(x: 32)
                Button(action: {}, label: {
                    Text("2023")
                        .font(.system(.subheadline, design: .rounded))
                        .bold()
                        .opacity(0.5)
                        .frame(alignment: .trailing)
                        .offset(x: 7)
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .opacity(0.5)
                })
                .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            HStack {
                Text("Total spent this year")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("¥" + formatNumber(getTotalSpent()))
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundStyle(colorScheme == .dark ? .orange : .primary)
            }
            .frame(maxWidth: 350)
            HStack {
                Text("Average per month this year")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("¥" + formatNumber(calculateAverageSpent(getTotalSpent())))
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundStyle(colorScheme == .dark ? .orange : .primary)
            }
            .frame(maxWidth: 350)
        }
    }
    
    // MARK: - detailed payment
    
    var statistics: some View {
        VStack {
            Text("Statistics".uppercased())
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .opacity(0.35)
            TransactionBriefChartView()
        }
    }
    
    private func getTotalSpent() -> Double {
        return payments.reduce(0.0) { $0 + ($1.transactionType == .expense ? $1.expense : 0.0) }
    }
    
    private func calculateAverageSpent(_ totalCost: Double) -> Double {
        let calender = Calendar.current
        return totalCost == 0 ? 0.0 : (totalCost / Double(calender.component(.month, from: Date())))
    }
    
    private func getBudgetLeftPercentage() -> Double {
        return userData.userBudget == 0 ? 1 : 1 - monthlyExpense / userData.userBudget
    }
}

func formatNumber(_ number: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: number)) ?? "0.00"
}

