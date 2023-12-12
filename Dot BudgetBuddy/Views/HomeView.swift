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

    @State private var currentTimePeriod = getTimeOfDay()
    @State private var isDetailSheetPresented = false
    @State private var userName = UserDefaults.standard.string(forKey: "userName") ?? "Ethan"
    @State private var inputText = ""
    @State private var isDeletionAlertPresented = false

    @Binding var isTabBarPresented: Bool

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
                    DetailedPaymentView(isPresented: $isDetailSheetPresented)
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
                Text("\(userName)")
                    .font(.system(size: 35, design: .rounded))
                    .fontWeight(.bold)
                    .frame(maxWidth: 350, alignment: .leading)
            }
            .foregroundStyle(colorScheme == .dark ? .orange : .primary)
            NavigationLink(destination: SettingsView()) {
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
            Text("Today")
                .font(.system(size: 30))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Divider()
            HStack {
                Text("¥34.0")
                    .font(.system(size: 25, design: .rounded))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("total")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .opacity(0.5)
                    .frame(alignment: .trailing)
            }
        }
        .padding(.all, 13)
        .frame(width: 175, height: 150)
        .background(.ultraThinMaterial, in:
            RoundedRectangle(cornerRadius: 25, style: .continuous))
//        .shadow(radius: 50, y: -3)
    }

    // MARK: - this month's payment

    var dashBoardOdMonth: some View {
        VStack {
            Text("This Month")
                .font(.system(size: 30))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Divider()
            HStack {
                Text("¥1984.5")
                    .font(.system(size: 25, design: .rounded))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("left")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .opacity(0.5)
                    .frame(alignment: .trailing)
            }
        }
        .padding(.all, 13)
        .frame(width: 175, height: 150)
        .background(.ultraThinMaterial, in:
            RoundedRectangle(cornerRadius: 25, style: .continuous))
    }

    // MARK: - payment list

    // FIXME: - Nested ForEach
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

    func sortedSections() -> [Date] {
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

    func transactionsForDate(_ date: Date) -> [Payment] {
        let truncatedDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return payments.filter { transaction in
            let transactionComponents = Calendar.current.dateComponents([.year, .month, .day], from: transaction.date)
            return truncatedDate.day == transactionComponents.day && truncatedDate.month == transactionComponents.month && truncatedDate.year == transactionComponents.year
        }
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
    HomeView(isTabBarPresented: .constant(false))
}
