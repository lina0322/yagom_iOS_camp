//
//  Dashboard.swift
//  BankManagerConsoleApp
//
//  Created by 임리나 on 2021/01/09.
//

import Foundation

class Dashboard {
    static func printMenu() {
        print(Menu.description, terminator: " ")
    }
        
    static func printStatus(for client: Client, about message: Message) {
        let message = String(format: message.rawValue, client.waitingNumber, client.priority.description, client.businessType.description)
        let format = DateFormatter()
        format.dateFormat = "ss.S"
        let now = Date()
        let date = format.string(from: now)
        print(message + " \(date)")
    }
    
    static func printCloseMessage(_ number: Int, _ time: TimeInterval?) {
        guard let time = time else {
            print(BankError.unknown.description)
            return
        }
        let message = String(format: Message.close.rawValue, number, time)
        print(message)
    }
}
