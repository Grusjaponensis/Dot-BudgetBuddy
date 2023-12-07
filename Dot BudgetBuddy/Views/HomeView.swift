//
//  MainFunctionView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 11/25/23.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var payments: [Payment]
    @State private var currentTimePeriod = getTimeOfDay()
    @State private var isDetailSheetPresented = false
    @Binding var isTabBarPresented: Bool
    @Environment(\.userName) private var userName
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    var temp = ["Category1", "Category2", "Category3"]
    
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

    // MARK: - payment detail

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
            RoundedRectangle(cornerRadius: 25, style: .continuous)
        )
    }
    
    var filteredPaymentList: some View {
        VStack {
            List {
                Section {
                    ForEach(payments, id: \.self) { payment in
                        HStack {
                            Text(payment.category)
                                .font(.system(size: 20, design: .rounded))
                                .bold()
                            Spacer()
                            VStack {
                                Text(String(format: "%.2f", payment.expense))
                                Text(payment.date.formatted(date: .numeric, time: .omitted))
                                    .font(.subheadline)
                                    .opacity(0.5)
                            }
                        }
                    }
                    .onDelete{ $0.forEach { modelContext.delete(payments[$0]) } }
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

struct UserNamePath: EnvironmentKey {
    static var defaultValue: String = "Ethan"
}

extension EnvironmentValues {
    var userName: String {
        get { self[UserNamePath.self] }
        set { self[UserNamePath.self] = newValue }
    }
}

#Preview {
    HomeView(isTabBarPresented: .constant(false))
}
