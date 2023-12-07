//
//  MainTabView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 12/5/23.
//

import SwiftUI

struct MainTabView: View {
    @Binding var selection: TabType
    @Binding var isAddViewPresent: Bool
    
    var body: some View {
        HStack {
            ForEach(0 ..< TabType.allCases.count, id: \.self) { index in
                Button {
                    if index == 1 {
                        isAddViewPresent.toggle()
                    }
                    self.selection = TabType.allCases[index]
                } label: {
                    Image(systemName: TabType.allCases[index].systemImage)
                        .font(.title3)
                        .fontWeight(index == 1 ? .bold : .regular)
                        .foregroundColor(selection == TabType.allCases[index] ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .scaleEffect(index == 1 ? 1.5 : 1.0)
                }
                .sheet(isPresented: $isAddViewPresent, content: {
                    AddView(isPresent: $isAddViewPresent)
                })
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .background(.orange)
        .cornerRadius(27)
        .shadow(radius: 10)
        .padding(.init(top: 10, leading: 44, bottom: 25, trailing: 44))
    }
}

enum TabType: String, CaseIterable {
    case home
    case add
    case settings

    var systemImage: String {
        switch self {
        case .home:
            "house"
        case .add:
            "plus"
        case .settings:
            "gear"
        }
    }

    var view: some View {
        Text(self.rawValue)
            .tabItem {
                Label(self.rawValue, systemImage: self.systemImage)
            }
    }
}

#Preview {
    MainTabView(selection: .constant(.home), isAddViewPresent: .constant(false))
}
