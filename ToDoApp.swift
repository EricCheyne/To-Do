//
//  ToDoApp.swift
//  ToDoApp
//
//  Created by Eric Cheyne on 10/7/24.
//

import SwiftUI
import UserNotifications

@main
struct ToDoApp: App {
    @StateObject private var viewModel = ToDoViewModel()
    
    init() {
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notifications permission: \(error.localizedDescription)")
            }
        }
    }
}
