//
//  ContentView.swift
//  ToDoApp
//
//  Created by Eric Cheyne on 10/7/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ToDoViewModel()
    @State private var newTaskName: String = ""
    @State private var reminderDate: Date? = nil
    @State private var editingItem: ToDoItem? // To store the item being edited
    @State private var isEditing: Bool = false // To toggle edit mode
    
    // State variables for the confirmation alert
    @State private var showDeleteAlert: Bool = false
    @State private var itemToDeleteIndex: IndexSet? // Store the index of the item to delete

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter a new task", text: $newTaskName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Date Picker for reminder
                DatePicker("Select Reminder Date", selection: .init(
                    get: { reminderDate ?? Date() },
                    set: { reminderDate = $0 }
                ), displayedComponents: [.date, .hourAndMinute])
                    .padding()
                
                List {
                    ForEach(viewModel.items) { item in
                        HStack {
                            Button(action: {
                                viewModel.toggleCompletion(for: item)
                            }) {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.isCompleted ? .green : .gray)
                            }
                            
                            Text(item.name)
                                .strikethrough(item.isCompleted)
                            
                            // Edit button
                            Button(action: {
                                startEditing(item)
                            }) {
                                Text("Edit")
                                    .foregroundColor(.blue)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .onDelete(perform: promptDeleteItem) // Prompt for confirmation here
                }
                
                // Undo button
                if viewModel.showUndoButton {
                    Button(action: {
                        viewModel.undoDelete()
                    }) {
                        Text("Undo Delete")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }

                Button(action: {
                    if isEditing, let editingItem = editingItem {
                        // If editing, update the item
                        viewModel.updateItem(editingItem, newName: newTaskName, reminderDate: reminderDate)
                        resetEditing()
                    } else if !newTaskName.isEmpty {
                        // If not editing, add a new item
                        viewModel.addItem(name: newTaskName, reminderDate: reminderDate)
                        resetInput()
                    }
                }) {
                    Text(isEditing ? "Update Task" : "Add Task")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("To-Do List")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Confirm Delete"),
                    message: Text("Are you sure you want to delete this task?"),
                    primaryButton: .destructive(Text("Delete")) {
                        // Delete the item if confirmed
                        if let indexSet = itemToDeleteIndex {
                            viewModel.deleteItem(at: indexSet)
                        }
                    },
                    secondaryButton: .cancel() // Cancel button
                )
            }
        }
        .padding()
    }
    
    // Function to prompt for delete confirmation
    private func promptDeleteItem(at indexSet: IndexSet) {
        itemToDeleteIndex = indexSet // Store the index set of the item to delete
        showDeleteAlert = true // Show the confirmation alert
    }

    // Function to start editing a task
    private func startEditing(_ item: ToDoItem) {
        editingItem = item
        newTaskName = item.name
        reminderDate = item.reminderDate
        isEditing = true
    }

    // Function to reset input fields
    private func resetInput() {
        newTaskName = ""
        reminderDate = nil
    }

    // Function to reset editing state
    private func resetEditing() {
        editingItem = nil
        newTaskName = ""
        reminderDate = nil
        isEditing = false
    }
}
