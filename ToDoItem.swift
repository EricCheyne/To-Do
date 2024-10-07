//
//  ToDoItem.swift
//  ToDoApp
//
//  Created by Eric Cheyne on 10/7/24.
//

import Foundation

struct ToDoItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var isCompleted: Bool = false
    var reminderDate: Date? // Optional date for the reminder
}
