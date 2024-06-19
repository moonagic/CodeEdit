//
//  TaskManager.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 09.06.24.
//

import Foundation
import Dispatch
import Combine

/// This class handles the execution of tasks
final class TaskManager: ObservableObject {
    @Published var activeTasks: [UUID: CEActiveTask] = [:]
    @Published var selectedTaskID: UUID?

    var workspaceSettings: CEWorkspaceSettings

    init(workspaceSettings: CEWorkspaceSettings) {
        self.workspaceSettings = workspaceSettings
    }

    var selectedTask: CETask? {
        if let selectedTaskID {
            return availableTasks.first { $0.id == selectedTaskID }
        } else {
            if let newSelectedTask = availableTasks.first {
                Task {
                    await MainActor.run {
                        self.selectedTaskID = newSelectedTask.id
                    }
                }
                return newSelectedTask
            }
        }
        return nil
    }

    var availableTasks: [CETask] {
        return workspaceSettings.preferences.tasks.items
    }

    var taskStatus: (UUID) -> CETaskStatus {
        return { taskID in
            return self.activeTasks[taskID]?.status ?? .stopped
        }
    }

    func executeActiveTask() {
        let task = workspaceSettings.preferences.tasks.items.first { $0.id == selectedTaskID }
        guard let task else { return }
        runTask(task: task)
    }

    func runTask(task: CETask) {
        // A process can only be started once, that means we have to renew the Process and Pipe
        // but don't initialise a new object.
        if activeTasks[task.id] != nil {
            activeTasks[task.id]!.renew()
            activeTasks[task.id]!.run()
        } else {
            let runningTask = CEActiveTask(task: task)
            runningTask.run()
            Task {
                await MainActor.run {
                    activeTasks[task.id] = runningTask
                }
            }
        }
    }
    private func createRunningTask(taskID: UUID, runningTask: CEActiveTask) async {
        await MainActor.run {
            activeTasks[taskID] = runningTask
        }
    }

    func terminateActiveTask() {
        let taskID = selectedTaskID
        guard let taskID else {
            return
        }

        terminateTask(taskID: taskID)
    }

    /// Suspends the task associated with the given task ID.
    ///
    /// Suspending a task means that the task's execution is paused. 
    /// The task will not run or consume CPU time until it is resumed.
    /// If there is no task associated with the given ID, or if the task is not currently running, 
    /// this method does nothing.
    ///
    /// - Parameter taskID: The ID of the task to suspend.
    func suspendTask(taskID: UUID) {
        if let process = activeTasks[taskID]?.process {
            process.suspend()
        }
    }

    /// Resumes the task associated with the given task ID.
    ///
    /// If there is no task associated with the given ID, or if the task is not currently suspended, 
    /// this method does nothing.
    ///
    /// - Parameter taskID: The ID of the task to resume.
    func resumeTask(taskID: UUID) {
        if let process = activeTasks[taskID]?.process {
            process.resume()
        }
    }

    /// Terminates the task associated with the given task ID.
    ///
    /// Terminating a task sends a SIGTERM signal to the process, which is a request to the process to stop execution.
    /// Most processes will stop when they receive a SIGTERM signal. 
    /// However, a process can choose to ignore this signal.
    ///
    /// If there is no task associated with the given ID, 
    /// or if the task is not currently running, this method does nothing.
    ///
    /// - Parameter taskID: The ID of the task to terminate.
    func terminateTask(taskID: UUID) {
        guard let process = activeTasks[taskID]?.process, process.isRunning else {
            return
        }
        process.terminate()
        process.waitUntilExit()
    }

    /// Interrupts the task associated with the given task ID.
    ///
    /// Interrupting a task sends a SIGINT signal to the process, which is a request to the process to stop execution.
    /// This is the same signal that is sent when you press Ctrl+C in a terminal.
    /// It's a polite request to the process to stop what it's doing and terminate.
    /// However, the process can choose to ignore this signal or handle it in a custom way.
    ///
    /// If there is no task associated with the given ID, or if the task is not currently running, 
    /// this method does nothing.
    ///
    /// - Parameter taskID: The ID of the task to interrupt.
    func interruptTask(taskID: UUID) {
        guard let process = activeTasks[taskID]?.process, process.isRunning else {
            return
        }
        process.interrupt()
        process.waitUntilExit()
    }

    func stopAllTasks() {
        for (id, _) in activeTasks {
            interruptTask(taskID: id)
        }
    }
}