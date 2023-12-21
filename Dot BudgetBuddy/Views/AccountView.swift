//
//  AccountView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 12/13/23.
//

import SwiftUI

struct AccountView: View {
    @State private var isPresented = false
    var body: some View {
        HStack {
            Button("show") {
                isPresented.toggle()
            }
            .popover(isPresented: $isPresented) {
                sheetView.presentationDetents([.height(400)])
            }
        }
    }

    var sheetView: some View {
        NavigationStack {
            VStack {
                Text("Hello!")
            }
            .navigationTitle("Hello")
            .navigationBarItems(trailing:
                Button("Done") {
                    isPresented.toggle()
                }
            )
        }
    }
}

#Preview {
    AccountView()
}
