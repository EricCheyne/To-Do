//
//  ToDoViewModel.swift
//  ToDoApp
//
//  Created by Eric Cheyne on 10/7/24.
//

import SwiftUI
import UserNotifications

class ToDoViewModel: ObservableObject {
    @Published var items: [ToDoItem] = [] {
        didSet {
            saveItems()
        }
    }
    @Published var recentlyDeletedItem: ToDoItem? // Temporary storage for the deleted item
    @Published var showUndoButton: Bool = false // Flag to control the visibility of the Undo button

    init() {
        loadItems()
    }
    
    func addItem(name: String, reminderDate: Date?) {
        let newItem = ToDoItem(name: name, reminderDate: reminderDate)
        items.append(newItem)
        
        if let reminderDate = reminderDate {
            scheduleNotification(for: newItem, on: reminderDate)
        }
    }

    func updateItem(_ item: ToDoItem, newName: String, reminderDate: Date?) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].name = newName
            items[index].reminderDate = reminderDate
            
            // Cancel existing notification if it exists
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
            
            // Schedule a new notification if reminderDate is set
            if let reminderDate = reminderDate {
                scheduleNotification(for: items[index], on: reminderDate)
            }
        }
    }
    
    func deleteItem(at indexSet: IndexSet) {
        indexSet.forEach { index in
            let itemToDelete = items[index]
            // Remove the existing notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [itemToDelete.id.uuidString])
            
            // Store the deleted item temporarily
            recentlyDeletedItem = itemToDelete
            items.remove(at: index)
            showUndoButton = true // Show the Undo button after deletion
            
            // Automatically hide the Undo button after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.showUndoButton = false
                self.recentlyDeletedItem = nil // Clear the deleted item after the timeout
            }
        }
    }
    
    func undoDelete() {
        if let itemToRestore = recentlyDeletedItem {
            items.append(itemToRestore)
            recentlyDeletedItem = nil // Clear the restored item
            showUndoButton = false // Hide the Undo button
        }
    }
    
    func toggleCompletion(for item: ToDoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
        }
    }

    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }

    private func loadItems() {
        if let savedData = UserDefaults.standard.data(forKey: "tasks") {
            if let decodedItems = try? JSONDecoder().decode([ToDoItem].self, from: savedData) {
                items = decodedItems
            }
        }
    }

    private func scheduleNotification(for item: ToDoItem, on date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Don't forget: \(item.name)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }
    }
}
