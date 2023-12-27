//
//  UserName.swift
//  Dot BudgetBuddy
//
//  Created by snow on 12/13/23.
//

import Foundation

class UserData: ObservableObject {
    @Published var userName: String = UserDefaults.standard.string(forKey: "userName") ?? "Ethan"
    @Published var userBudget: Double = UserDefaults.standard.double(forKey: "userBudget")
    @Published var userLeftMoney: Double = UserDefaults.standard.double(forKey: "userLeftMoney")
    
    func setUserName(_ newName: String) {
        userName = newName
        UserDefaults.standard.setValue(newName, forKey: "userName")
    }
    
    func setUserBudget(_ newBudget: Double) {
        userBudget = newBudget
        UserDefaults.standard.setValue(newBudget, forKey: "userBudget")
    }
    
    func setUserLeftMoney(_ leftAmount: Double) { userLeftMoney = leftAmount }
}
