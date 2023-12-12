//
//  AddView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 11/28/23.
//

import SwiftData
import SwiftUI

struct AddView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    
    @State private var selectedTransactionType: TransactionType = .expense
    @State private var selectedCategoryIndex: Int?
    @State private var selectedDate = Date()
    @State private var inputExpenceWithAnimation = ""
    @State private var inputExpence = ""
    @State private var inputNotes = ""
    @State private var isInputValid = false
    
    private static var correspondingColor: [Color] = [.cyan, .pink, .blue, .orange, .purple, .green]
    
    @Binding var isPresent: Bool
    
    
    var body: some View {
        VStack {
            title
            addCategory
            if selectedTransactionType == .expense {
                expenceCategory
            } else {
                incomeCategory
            }
            addTransactionAmount
            addButton
        }
    }
    
    // MARK: - title

    var title: some View {
        Text("Record Something?")
            .font(.system(size: 40, design: .rounded))
            .fontWeight(.bold)
            .foregroundStyle(colorScheme == .dark ? .orange : .primary)
            .frame(maxWidth: 350, alignment: .leading)
            .padding(.top, 20)
    }
    
    // MARK: - add

    var addCategory: some View {
        VStack {
            Text("Category".uppercased())
                .font(.system(.title3, design: .rounded))
                .bold()
                .opacity(0.5)
                .padding(.vertical, 4)
                .frame(maxWidth: 350, alignment: .leading)
            Picker("Type", selection: $selectedTransactionType) {
                Text("Expence")
                    .tag(TransactionType.expense)
                Text("Income")
                    .tag(TransactionType.income)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 350)
            .padding(.bottom)
        }
    }
    
    // MARK: - expense

    var expenceCategory: some View {
        addTransactionCategory(transactionImage: expenceImages, colors: AddView.correspondingColor, transactionType: .expense)
    }
    
    // MARK: - income

    var incomeCategory: some View {
        addTransactionCategory(transactionImage: incomeImages, colors: AddView.correspondingColor, transactionType: .income)
    }
        
    var addTransactionAmount: some View {
        VStack {
            Text(selectedTransactionType == .expense ? "Expence".uppercased() : "Income".uppercased())
                .font(.system(.title3, design: .rounded))
                .bold()
                .opacity(0.5)
                .frame(maxWidth: 350, alignment: .leading)
                .padding(.top, 20)
            VStack {
                TextField(text: $inputExpenceWithAnimation) {
                    Text("¥0.00")
                        .font(.system(.title, design: .rounded))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.system(.title, design: .monospaced))
                .bold()
                .keyboardType(.decimalPad)
                .frame(maxWidth: 335)
                .onChange(of: inputExpenceWithAnimation) { withAnimation { inputExpence = inputExpenceWithAnimation } }
                Divider()
                HStack {
                    DatePicker("", selection: $selectedDate)
                        .labelsHidden()
                        .frame(maxWidth: 350, alignment: .leading)
                    TextField(text: $inputNotes) {
                        Text("click to add notes")
                            .font(.subheadline)
                            .frame(maxWidth: 10, alignment: .center)
                    }
                    .font(.subheadline)
                    .frame(maxWidth: 335)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .frame(maxWidth: 350, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .foregroundStyle(.ultraThinMaterial.opacity(0.7))
                    .frame(width: 360, height: 120)
            )
        }
    }
        
    var addButton: some View {
        Button(action: {
            recordPaymentToModel()
            isPresent.toggle()
        }, label: {
            Text("Record")
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .frame(maxWidth: .infinity)
        })
        .background(
            Capsule()
                .frame(width: 350, height: 50)
                .foregroundStyle(inputExpence.isEmpty || selectedCategoryIndex == nil ? .gray.opacity(0.6) : .orange)
        )
        .padding(.top, 40)
        .disabled(inputExpence.isEmpty || selectedCategoryIndex == nil)
    }
    
    func addTransactionCategory(transactionImage: [String], colors: [Color], transactionType: TransactionType) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 40) {
            ForEach(colors.indices, id: \.self) { index in
                let image = transactionImage[index]
                let color = colors[index]
                Button(action: { selectedCategoryIndex = index }, label: {
                    VStack {
                        ZStack {
                            if selectedCategoryIndex == index {
                                Circle()
                                    .frame(maxWidth: 80, maxHeight: 80)
                                    .foregroundStyle(color)
                                    .opacity(0.8)
                            }
                            Circle()
                                .stroke(lineWidth: 4)
                                .frame(maxWidth: 80, maxHeight: 80)
                                .foregroundStyle(color)
                                .shadow(radius: selectedCategoryIndex == index ? 10 : 1)
                            Image(systemName: image)
                                .font(.system(size: 35))
                                .foregroundStyle(selectedCategoryIndex == index ? .white : color)
                                .shadow(radius: 1)
                        }
                        .frame(maxWidth: 130)
                        switch transactionType {
                            case.expense:
                            Text(PaymentCategory.allCases[index].rawValue)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(colorScheme == .dark ? .white : .primary)
                                .bold()
                        case .income:
                            Text(IncomeCategory.allCases[index].rawValue)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(colorScheme == .dark ? .white : .primary)
                                .bold()
                        }
                    }
                })
            }
        }
        .frame(maxWidth: 340, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                .foregroundStyle(.ultraThinMaterial.opacity(0.7))
                .frame(width: 360, height: 268)
        )
    }
        
    func recordPaymentToModel() {
        if let categoryIndex = selectedCategoryIndex, !inputExpence.isEmpty {
            let newPayment = Payment(
                transactionType: selectedTransactionType,
                category: selectedTransactionType == .expense ? PaymentCategory.allCases[categoryIndex].rawValue : IncomeCategory.allCases[categoryIndex].rawValue,
                date: selectedDate,
                expense: Double(inputExpence) ?? 0.0,
                description: inputNotes
            )
            modelContext.insert(newPayment)
            print(selectedCategoryIndex ?? -1)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Payment.self, configurations: config)
        let example = Payment(category: PaymentCategory.entertainment.rawValue, expense: 648, description: "For W")
        return AddView(isPresent: .constant(false))
    } catch {
        fatalError("Fatal Error!")
    }
}
