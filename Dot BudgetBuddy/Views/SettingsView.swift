//
//  SettingsView.swift
//  Dot BudgetBuddy
//
//  Created by snow on 12/5/23.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.userName) var userName

    var body: some View {
        NavigationStack {
            List {
                VStack {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 32))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.blue, .blue.opacity(0.35))
                        .padding()
                        .background(Circle().fill(.ultraThinMaterial))
                        .background(
                            Image(systemName: "hexagon.fill")
                                .font(.system(size: 200))
                                .foregroundStyle(.linearGradient(colors: [.blue, .gray], startPoint: .bottom, endPoint: .top))
                                .offset(y: -100)
                        )
                    Text(userName)
                        .font(.system(.title, design: .rounded))
                        .bold()
                    HStack {
                        Image(systemName: "location")
                            .imageScale(.small)
                            .opacity(0.5)
                        Text("Katzdale")
                            .opacity(0.6)
                    }
                }
                .frame(maxWidth: .infinity)
                Section {
                    NavigationLink { AccoutView()} label: {
                        HStack {
                            Image(systemName: "gear")
                            Text("Account")
                        }
                        .offset(x: -5)
                    }
                    NavigationLink { AccoutView()} label: {
                        HStack {
                            Image(systemName: "questionmark")
                            Text("Help")
                                .offset(x: 5)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct AccoutView: View {
    var body: some View {
        HStack {
            
        }
    }
}

#Preview {
    SettingsView()
}
