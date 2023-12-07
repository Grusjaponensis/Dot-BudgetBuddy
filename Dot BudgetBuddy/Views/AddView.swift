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
    @Query private var payment: [Payment]
    @State private var selectedCategoryIndex: Int?
    @State private var selectedDate = Date()
    @State private var inputExpenceWithAnimation = ""
    @State private var inputExpence = ""
    @State private var inputNotes = ""
    @State private var isInputValid = false
    @Binding var isPresent: Bool
    private static var categoryImages = ["takeoutbag.and.cup.and.straw", "car", "gamecontroller", "handbag.fill", "calendar", "figure.run"]
    private static var correspondingColor: [Color] = [.cyan, .pink, .blue, .orange, .purple, .green]
    
    var body: some View {
        VStack {
            title
            addCategory
            addExpense
            addButton
            Spacer()
        }
    }
    
    // MARK: - title
    var title: some View {
        Text("Record Something?")
            .font(.system(size: 40, design: .rounded))
            .fontWeight(.bold)
            .foregroundStyle(colorScheme == .dark ? .orange : .primary)
            .frame(maxWidth: 350, alignment: .leading)
            .padding(.horizontal)
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
                .padding(.bottom, 10)
                .frame(maxWidth: 350, alignment: .leading)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 40) {
                ForEach(AddView.categoryImages.indices, id: \.self) { index in
                    let image = AddView.categoryImages[index]
                    let color = AddView.correspondingColor[index]
                    Button(action: { selectedCategoryIndex = index }, label: {
                        VStack {
                            ZStack {
                                if selectedCategoryIndex == index {
                                    Circle()
                                        .frame(maxWidth: 90, maxHeight: 90)
                                        .foregroundStyle(color)
                                        .opacity(0.8)
                                }
                                Circle()
                                    .stroke(lineWidth: 4)
                                    .frame(maxWidth: 90, maxHeight: 90)
                                    .foregroundStyle(color)
                                    .shadow(radius: selectedCategoryIndex == index ? 10 : 1)
                                Image(systemName: image)
                                    .font(.system(size: 40))
                                    .foregroundStyle(selectedCategoryIndex == index ? .white : color)
                                    .shadow(radius: 1)
                            }
                            .frame(maxWidth: 130)
                            Text(PaymentCategory.allCases[index].rawValue)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(colorScheme == .dark ? .white : .primary)
                                .bold()
                        }
                    })
                }
            }
            .frame(maxWidth: 340, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .foregroundStyle(.ultraThinMaterial.opacity(0.7))
                    .frame(width: 360, height: 295)
            )

        }
    }
        
    var addExpense: some View {
        VStack {
            Text("Expence".uppercased())
                .font(.system(.title3, design: .rounded))
                .bold()
                .opacity(0.5)
                .frame(maxWidth: 350, alignment: .leading)
                .padding(.top, 35)
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
            .padding(.vertical, 15)
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
                .foregroundStyle(inputExpence.isEmpty ? .gray.opacity(0.6) : .orange)
        )
        .padding(.top, 40)
        .disabled(inputExpence.isEmpty)
    }
        
    func recordPaymentToModel() {
        if let categoryIndex = selectedCategoryIndex, !inputExpence.isEmpty {
            let newPayment = Payment(
                category: PaymentCategory.allCases[categoryIndex].rawValue,
                date: selectedDate,
                expense: Double(inputExpence) ?? 0.0,
                description: inputNotes
            )
            modelContext.insert(newPayment)
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
