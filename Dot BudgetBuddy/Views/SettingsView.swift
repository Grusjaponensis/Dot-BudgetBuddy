//
//  SettingsView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 12/5/23.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var userData: UserData
    
    @State private var budget = UserDefaults.standard.double(forKey: "userBudget")
    @State private var inputBudget: String = ""
    @State private var inputUserName: String = ""
    @State private var selectedDate = Date()
    @State private var isBudgetSettingPresented = false
    @State private var isUserNameSettingPresented = false

    var body: some View {
        NavigationStack {
            List {
                profile
                Section {
                    setBudget
                }

                Section {
                    NavigationLink { FAQ } label: {
                        HStack {
                            Image(systemName: "questionmark")
                            Text("Help").offset(x: 5)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    var profile: some View {
        VStack {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 32))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.pink, .blue.opacity(colorScheme == .dark ? 0.5 : 0.35))
                .padding()
                .background(Circle().fill(.ultraThinMaterial))
                .background(
                    Image(systemName: "hexagon.fill")
                        .font(.system(size: 200))
                        .foregroundStyle(.linearGradient(colors: [.orange, .red], startPoint: .bottom, endPoint: .top))
                        .offset(y: -100)
                )
            Button(action: { isUserNameSettingPresented.toggle() }, label: {
                Text(userData.userName)
                    .font(.system(.title, design: .rounded))
                    .bold()
            })
            .popover(isPresented: $isUserNameSettingPresented) {
                VStack {
                    Text("How would you like to be addressed?")
                        .font(.system(size: 25, design: .rounded))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                    TextField("Your name, please?", text: $inputUserName)
                        .onSubmit {
                            let newName = inputUserName.isEmpty ? "Ethan" : inputUserName
                            userData.setUserName(newName)
                            inputUserName = ""
                            isUserNameSettingPresented.toggle()
                        }
                        .frame(maxWidth: 330)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 7)
                        .background(.ultraThinMaterial, in:
                            RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                        .presentationDetents([.height(200)])
                        .presentationDragIndicator(.visible)
                    Spacer()
                }
                .frame(maxWidth: 350, minHeight: 35)
            }
            .tint(.primary)
            HStack {
                Image(systemName: "location")
                    .imageScale(.small)
                Text("Katzdale")
                    .opacity(0.6)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - FAQ

    var FAQ: some View {
        Text("Sorry, I can't help you.")
            .font(.system(.title, design: .serif))
            .bold()
    }

    // MARK: - set budget

    var setBudget: some View {
        Button(action: { isBudgetSettingPresented.toggle() }, label: {
            HStack {
                Image(systemName: "creditcard.fill")
                    .offset(x: -5)
                Text("Budget")
                    .offset(x: -6)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .opacity(0.25)
                    .bold()
            }
            .tint(.primary)
        })
        .popover(isPresented: $isBudgetSettingPresented) {
            VStack {
                Text("Set monthly budget")
                    .font(.system(size: 25, design: .rounded))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                Spacer()
                HStack {
                    TextField(text: $inputBudget) {
                        Text(" Tap to input")
                            .frame(maxWidth: 330)
                    }
                    .onSubmit {
                        userData.setUserBudget(Double(inputBudget) ?? 0.0)
                        inputBudget = ""
                        isBudgetSettingPresented.toggle()
                    }
                    .keyboardType(.decimalPad)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 7)
                .background(.ultraThinMaterial, in:
                    RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                Spacer()
                Text("tips: Remember to adhere to the goals you set for yourself!")
                    .opacity(0.5)
            }
            .frame(maxWidth: 350, minHeight: 35)
            .presentationDetents([.height(200)])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    SettingsView(userData: UserData())
}
