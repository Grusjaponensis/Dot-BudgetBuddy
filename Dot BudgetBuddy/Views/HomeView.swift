//
//  MainFunctionView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 11/25/23.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(sort: \Payment.date, order: .reverse) private var payments: [Payment]

    @ObservedObject var userData: UserData

    @State private var currentTimePeriod = getTimeOfDay()
    @State private var isDetailSheetPresented = false
    @State private var inputText = ""
    @State private var isDeletionAlertPresented = false

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            greeting
                .padding(.bottom)
            detailedReviewButton
                .onTapGesture {
                    isDetailSheetPresented.toggle()
                }
                .sheet(isPresented: $isDetailSheetPresented) {
                    DetailedPaymentView(userData: userData, isPresented: $isDetailSheetPresented,
                                        monthlyExpense: getMonthlyExpense(),
                                        yearlyExpense: getYearlyExpense(),
                                        monthlyEarning: getMonthlyEarnings())
                }
            HStack {
                dashBoardOfToday
                dashBoardOdMonth
            }
            .padding(.bottom, 10)
            filteredPaymentList
        }
    }

    // MARK: - greeting

    var greeting: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Good \(currentTimePeriod.rawValue),")
                    .font(.system(size: 40, design: .rounded))
                    .fontWeight(.bold)
                    .frame(maxWidth: 350, alignment: .leading)
                Text(userData.userName)
                    .font(.system(size: 35, design: .rounded))
                    .fontWeight(.bold)
                    .frame(maxWidth: 350, alignment: .leading)
            }
            .foregroundStyle(colorScheme == .dark ? .orange : .primary)
            NavigationLink(destination: SettingsView(userData: userData)) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 50))
                    .foregroundStyle(.linearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                    .shadow(radius: 1)
                    .offset(x: -5)
            }
        }
        .frame(maxWidth: 350)
    }

    // MARK: - payment detail button

    var detailedReviewButton: some View {
        HStack {
            Text("REVIEW")
                .font(.headline)
                .opacity(0.4)
            Spacer()
            Text("Details")
                .font(.headline)
                .opacity(0.3)
            Image(systemName: "chevron.right")
                .opacity(0.4)
        }
        .frame(width: 350)
    }

    // MARK: - today's payment

    var dashBoardOfToday: some View {
        VStack {
            Text("Today's Expense")
                .font(.system(size: 20, design: .rounded))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Text("total")
                .font(.system(size: 15))
                .fontWeight(.bold)
                .opacity(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            HStack {
                Text("¥\(formatNumber(getTodayExpence()))")
                    .font(.system(size: 22, design: .rounded))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
        }
        .padding(.all, 13)
        .frame(width: 175, height: 150)
        .background(.ultraThinMaterial, in:
            RoundedRectangle(cornerRadius: 25, style: .continuous))
    }

    // MARK: - this month's payment

    var dashBoardOdMonth: some View {
        VStack {
            Text("Monthly Budget")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            if getMonthlyExpense() > userData.userBudget {
                Text("over")
                    .font(.system(size: 15))
                    .foregroundStyle(.red)
                    .fontWeight(.bold)
                    .opacity(0.9)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("left")
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                    .opacity(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Divider()
            HStack {
                Text("¥\(formatNumber(userData.userBudget - getMonthlyExpense()))")
                    .font(.system(size: 22, design: .rounded))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.all, 13)
        .frame(width: 175, height: 150)
        .background(.ultraThinMaterial, in:
            RoundedRectangle(cornerRadius: 25, style: .continuous))
    }

    // MARK: - payment list

    var filteredPaymentList: some View {
        VStack {
            List {
                ForEach(sortedSections(), id: \.self) { section in
                    Section(header: Text(section.formattedDate).font(.subheadline).bold()) {
                        ForEach(transactionsForDate(section), id: \.self) { payment in
                            TransactionListView(payment: payment)
                        }
                        .onDelete { $0.forEach { modelContext.delete(payments[$0]) } }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .frame(maxWidth: 370)
                    .foregroundStyle(.regularMaterial)
            )
        }
    }

    private func sortedSections() -> [Date] {
        let dateDictionary = payments.reduce(into: [String: Date]()) { result, payment in
            let components = Calendar.current.dateComponents([.year, .month, .day], from: payment.date)
            if let truncatedDate = Calendar.current.date(from: components) {
                let key = DateFormatter.localizedString(from: truncatedDate, dateStyle: .medium, timeStyle: .none)
                result[key] = truncatedDate
            }
        }
        let sortedDates = dateDictionary.values.sorted(by: >)
        return sortedDates
    }

    private func transactionsForDate(_ date: Date) -> [Payment] {
        let truncatedDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return payments.filter { transaction in
            let transactionComponents = Calendar.current.dateComponents([.year, .month, .day], from: transaction.date)
            return truncatedDate.day == transactionComponents.day && truncatedDate.month == transactionComponents.month && truncatedDate.year == transactionComponents.year
        }
    }

    private func getTodayExpence() -> Double {
        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date.now)
        return payments.reduce(0.0) { sum, transaction in
            let transactionDate = Calendar.current.dateComponents([.year, .month, .day], from: transaction.date)
            let condition = transactionDate == today && transaction.transactionType == .expense
            return sum + (condition ? transaction.expense : 0.0)
        }
    }

    private func getMonthlyExpense() -> Double {
        let thisMonth = Calendar.current.dateComponents([.year, .month], from: Date.now)
        let monthlyExpense = payments.reduce(0.0) { sum, transaction in
            let transactionDate = Calendar.current.dateComponents([.year, .month], from: transaction.date)
            if transactionDate == thisMonth {
                let expenseAmount = (transaction.transactionType == .expense) ? transaction.expense : 0.0
                return sum + expenseAmount
            } else {
                return sum
            }
        }
        return monthlyExpense
    }
    
    private func getMonthlyEarnings() -> Double {
        let thisMonth = Calendar.current.dateComponents([.year, .month], from: Date.now)
        let monthlyEarnings = payments.reduce(0.0) { sum, transaction in
            let transactionDate = Calendar.current.dateComponents([.year, .month], from: transaction.date)
            if transactionDate == thisMonth {
                let earning = (transaction.transactionType == .income) ? transaction.expense : 0.0
                return sum + earning
            } else {
                return sum
            }
        }
        return monthlyEarnings
    }
    
    private func getYearlyExpense() -> Double {
        let thisYear = Calendar.current.dateComponents([.year], from: Date.now)
        let yearlyExpense = payments.reduce(0.0) { sum, transaction in
            let transactionDate = Calendar.current.dateComponents([.year], from: transaction.date)
            if transactionDate == thisYear {
                let expenseAmount = (transaction.transactionType == .expense) ? transaction.expense : 0
                return sum + expenseAmount
            } else {
                return sum
            }
        }
        return yearlyExpense

    }
}

enum TimeOfDay: String {
    case morning = "Morning"
    case noon = "Noon"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case night = "Night"
}

private func getTimeOfDay() -> TimeOfDay {
    let currentDate = Date()
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: currentDate)

    switch hour {
    case 6..<12:
        return .morning
    case 12:
        return .noon
    case 13..<18:
        return .afternoon
    case 18..<24:
        return .evening
    default:
        return .night
    }
}

extension Date {
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd EEEE"
        return dateFormatter.string(from: self)
    }
}

#Preview {
    HomeView(userData: UserData())
}
