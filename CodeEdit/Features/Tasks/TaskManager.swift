//
//  TaskManager.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 09.06.24.
//

import Foundation

/// This class handles the execution of tasks
final class TaskManager: ObservableObject {
    @Published var availableTask: Set<CETask>? = []
    @Published var activeTasks: Set<CETaskRun> = []
    @Published var selectedTaskID: UUID?

    init() {
//        self.activeTask = getTasks().first
    }

    /// Gets the current available tasks
    func getTasks() -> [CETask] {
        // TODO: Replace with actual tasks
        return [
//            TestTask(name: "dev"),
//            TestTask(name: "backend"),
//            TestTask(name: "auth"),
//            TestTask(name: "test")
            CETask(name: "dev", target: "test", workingDirectory: "test", command: "ls", environmentVariables: [])
        ]
    }

    /// Executes the active task
    func executeActiveTask() {
        // find task
//        guard let task = availableTask?.first(where: { $0.id == selectedTaskID }) else {
//            return
//        }
        let task =  CETask(name: "dev", target: "test", workingDirectory: "test", command: "ls", environmentVariables: [])
        let newActiveTask = CETaskRun(task: task)
        activeTasks.insert(newActiveTask)
        Task.detached {
            try? await newActiveTask.start()
        }
    }

//    func runTask() -> AsyncThrowingMapSequence<LiveCommandStream, Progress> {
//        let command = "ls"
//
//
//    }
//
//    func runLive(_ command: String) -> LiveCommandStream {
//
//    }

    func stopTask() { }
}
