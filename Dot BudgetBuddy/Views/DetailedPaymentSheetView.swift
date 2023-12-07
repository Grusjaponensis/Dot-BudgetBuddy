//
//  DetailedPaymentSheetView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 11/26/23.
//

import SwiftUI
import SwiftData

struct DetailedPaymentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    @Query var payments: [Payment]
    @Binding var isPresented: Bool
    @State var isBudgetExceed = false
    @State var budgetLeftPercentage = 0.806
    @State var totalCostThisYear = 0.0

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                title
                totalSpent
                Divider()
                yearlySpent
                detailPayment
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button(action: { isPresented.toggle() }) {
                    Text("Done").foregroundStyle(.orange)
                }
            )
            .navigationBarItems(trailing: Button(action: {addSampleData(modelContext: context)}) {
                Text("Add Sample").foregroundStyle(.orange)
            })
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
            Text("¥475.64")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(colorScheme == .dark ? .orange : .primary)
            HStack {
                Text("¥1984.50")
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .opacity(0.5)
                    .frame(alignment: .trailing)
                if isBudgetExceed == true {
                    Text("over")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.red)
                        .bold()
                        .frame(alignment: .leading)
                } else {
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
                    .trim(from: 0.0, to: budgetLeftPercentage)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.red, .orange, .red]),
                            center: .center,
                            angle: .zero
                        ),
                        style: .init(lineWidth: 20, lineCap: .round, lineJoin: .round)
                    )
                    .animation(.easeInOut(duration: 1), value: budgetLeftPercentage)
                Text(
                    Double(String(format: "%.2f", budgetLeftPercentage))!
                        .formatted(.percent)
                )
                .font(.system(.title, design: .rounded))
                .bold()
                .foregroundStyle(.orange)
            }
            .frame(maxWidth: 130, maxHeight: 170)
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
    
    var detailPayment: some View {
        ScrollView {
            ForEach(payments, id: \.self) { payment in
                HStack {
                    Text(payment.category)
                        .bold()
                        .font(.system(.headline, design: .rounded))
                    Spacer()
                    VStack {
                        Text(String(format: "%.2f", payment.expense))
                            .font(.system(.subheadline, design: .rounded))
                        Text(payment.date.formatted(date: .numeric, time: .omitted))
                            .font(.system(.footnote, design: .rounded))
                            .opacity(0.5)
                    }
                }
                Divider()
            }
            .padding(.all, 15)
            .padding(.horizontal, 8)
        }
    }
    
    func getTotalSpent() -> Double {
        var sumPayment = 0.0
        payments.forEach { sumPayment += $0.expense }
        return sumPayment
    }
}

/// categories: Food & Drink, Transpotation, Entertainment, Shopping, Subscriptions, Sports
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
                   _ day: Int = Calendar.current.component(.day, from: Date())) -> Date {
    // FIXME: cannot handle invalid date, add try-catch block
    let date = DateComponents(year: year, month: month, day: day)
    return Calendar.current.date(from: date) ?? Date()
}

//#Preview {
//    do {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try ModelContainer(for: Payment.self, configurations: config)
//        let example = Payment(category: PaymentCategory.entertainment.rawValue, expense: 648, description: "For W")
//        return DetailedPaymentView(_payments: Query(), isPresented: .constant(false)).modelContainer(container)
//    } catch {
//        fatalError("Fatal Error!")
//    }
//}
