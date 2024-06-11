//
//  CurrentTasks.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 10.06.24.
//

import Foundation
import Combine

/// Reflects changes in the current tasks to the UI.
///
/// Usage:
/// ```swift
/// @StateObject var listener = CurrentTasksListener()
/// ```
class CurrentTasksListener: ObservableObject {
    @Service var currentTasks: TaskNotificationHandler
    private var cancellables = Set<AnyCancellable>()

    init() {
        currentTasks.$tasks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}

/// Example Usage:
/// ```swift
/// func createTask() {
///     let userInfo: [String: Any] = [
///         "id": "uniqueTaskID",
///         "action": "create",
///         "title": "Task Title"
///     ]
///     NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: userInfo)
/// }
///
///
/// func updateTask() {
///     var userInfo: [String: Any] = [
///         "id": "uniqueTaskID",
///         "action": "update",
///         "title": "Updated Task Title"
///     ]
///     userInfo["message"] = "Updated Task Message"  // Optional
///     userInfo["percentage"] = 0.50  // Optional
///
///
///     NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: userInfo)
/// }
///
/// func deleteTask() {
///     let userInfo: [String: Any] = [
///         "id": "uniqueTaskID",
///         "action": "delete"
///     ]
///     NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: userInfo)
/// }
/// ```
class TaskNotificationHandler {
    @Published var tasks: [RunningTask] = []
    // Could use OrderedDictionary, but removing and inserting at the start has linear complexity
    // @Published var tasks: OrderedDictionary<String, RunningTask> = [:]

    init() {
        print("OBSERVING")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotification(_:)),
            name: .taskNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .taskNotification, object: nil)
    }

    // Handles notifications about task events
    @objc
    private func handleNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let taskID = userInfo["id"] as? String,
              let action = userInfo["action"] as? String else { return }

        switch action {
        case "create", "createWithPriority":
            createTask(task: userInfo)
        case "update":
            updateTask(task: userInfo)
        case "delete":
            deleteTask(taskID: taskID)
        default:
            break
        }
    }

    private func createTask(task: [AnyHashable: Any]) {
        guard let title = task["title"] as? String,
              let id = task["id"] as? String,
              let action = task["action"] as? String else {
            return
        }

        let task = RunningTask(
            id: id,
            title: title,
            message: task["message"] as? String,
            percentage: task["percentage"] as? Double,
            isLoading: task["isLoading"] as? Bool ?? false
        )

        if action == "create" {
            tasks.append(task)
        } else {
            tasks.insert(task, at: 0)
        }
    }

    private func updateTask(task: [AnyHashable: Any]) {
        guard let taskID = task["id"] as? String else { return }

        if let index = tasks.firstIndex(where: { $0.id == taskID }) {
            if let title = task["title"] as? String {
                tasks[index].title = title
            }
            if let message = task["message"] as? String {
                tasks[index].message = message
            }
            if let percentage = task["percentage"] as? Double {
                tasks[index].percentage = percentage
            }
            if let isLoading = task["isLoading"] as? Bool {
                tasks[index].isLoading = isLoading
            }
        }
    }

    /// Deletes a task with the specified ID.
    ///
    /// - Parameter taskID: The ID of the task to delete.
    private func deleteTask(taskID: String) {
        tasks.removeAll { $0.id == taskID }
    }

    func getTasks() -> [RunningTask] {
        return tasks
    }
}

extension Notification.Name {
    static let taskNotification = Notification.Name("taskNotification")
}

class CurrentTasks2: ObservableObject {
    static let shared = CurrentTasks2()

    @Published private(set) var tasks: [RunningTask] = []

    private init() {}

    func createTask(id: String, name: String, title: String, message: String, percentage: Double) {
        let task = RunningTask(id: id, title: title, message: message, percentage: percentage)
        tasks.append(task)
    }

    func updateTask(id: String, title: String? = nil, message: String? = nil, percentage: Double? = nil) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        if let title = title { tasks[index].title = title }
        if let message = message { tasks[index].message = message }
        if let percentage = percentage { tasks[index].percentage = percentage }
    }

    func deleteTask(id: String) {
        tasks.removeAll { $0.id == id }
    }

    func getTasks() -> [RunningTask] {
        return tasks
    }
}
