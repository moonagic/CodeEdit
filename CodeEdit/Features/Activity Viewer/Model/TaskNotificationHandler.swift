//
//  CurrentTasks.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 10.06.24.
//

import Foundation
import Combine

/// The `TaskNotificationListener` class observes task notifications from the `TaskNotificationHandler`
/// and updates its state to reflect changes in the task notifications.
class TaskNotificationListener: ObservableObject {
    @Service var currentTaskNotifications: TaskNotificationHandler
    private var cancellables = Set<AnyCancellable>()

    init() {
        currentTaskNotifications.$notifications
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}

/// Handles task-related notifications and manages a list of tasks.
///
/// This class observes notifications with the name `.taskNotification` and performs actions
/// such as creating, updating, or deleting tasks based on the information in the notification.
/// When creating a task, it is appended to the end of the array. 
/// The activity viewer only shows the first item in the array.
/// Use `"action": "createWithPriority"` to insert the task at the beginning of the array,
/// immediately displaying the desired notification.
///
/// ## Example Usage:
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
/// func createTaskWithPriority() {
///     let userInfo: [String: Any] = [
///         "id": "uniqueTaskID",
///         "action": "createWithPriority",
///         "title": "Priority Task Title"
///     ]
///     NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: userInfo)
/// }
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
///
/// - Important: Please refer to ``CodeEdit/NotificationModel`` and ensure you pass the correct values.
class TaskNotificationHandler {
    @Published var notifications: [NotificationModel] = []

    // Could use OrderedDictionary, but removing and inserting at the start has linear complexity
    // @Published var tasks: OrderedDictionary<String, RunningTask> = [:]

    /// Initialises a new `TaskNotificationHandler` and starts observing for task notifications.
    init() {
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

    /// Handles notifications about task events.
    ///
    /// - Parameter notification: The notification containing task information.
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

    /// Creates a new task or inserts it at the beginning of the tasks array based on the action.
    ///
    /// - Parameter task: A dictionary containing task information.
    private func createTask(task: [AnyHashable: Any]) {
        guard let title = task["title"] as? String,
              let id = task["id"] as? String,
              let action = task["action"] as? String else {
            return
        }

        let task = NotificationModel(
            id: id,
            title: title,
            message: task["message"] as? String,
            percentage: task["percentage"] as? Double,
            isLoading: task["isLoading"] as? Bool ?? false
        )

        if action == "create" {
            notifications.append(task)
        } else {
            notifications.insert(task, at: 0)
        }
    }

    /// Updates an existing task with new information.
    ///
    /// - Parameter task: A dictionary containing task information.
    private func updateTask(task: [AnyHashable: Any]) { 
        guard let taskID = task["id"] as? String else { return }

        if let index = notifications.firstIndex(where: { $0.id == taskID }) {
            if let title = task["title"] as? String {
                notifications[index].title = title
            }
            if let message = task["message"] as? String {
                notifications[index].message = message
            }
            if let percentage = task["percentage"] as? Double {
                notifications[index].percentage = percentage
            }
            if let isLoading = task["isLoading"] as? Bool {
                notifications[index].isLoading = isLoading
            }
        }
    }

    private func deleteTask(taskID: String) {
        notifications.removeAll { $0.id == taskID }
    }

    func getTasks() -> [NotificationModel] {
        return notifications
    }
}

extension Notification.Name {
    static let taskNotification = Notification.Name("taskNotification")
}
