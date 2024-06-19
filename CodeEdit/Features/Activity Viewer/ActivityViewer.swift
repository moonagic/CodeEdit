//
//  ActivityViewer.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 09.06.24.
//
import SwiftUI
import Combine

/// A view that shows the activity bar and the current status of any executed task
struct ActivityViewer: View {
    @Environment(\.colorScheme)
    var colorScheme

    @State private var projectSettings: CEWorkspaceSettingsData.ProjectSettings?
    @State private var tasksSettings: CEWorkspaceSettingsData.TasksSettings?

    @State private var isHoveringScheme: Bool = false
    @State private var isPresentedScheme: Bool = false
    @State private var isHoveringTasks: Bool = false
    @State private var isPresentedTasks: Bool = false

    private var workspaceFileManager: CEWorkspaceFileManager?

    @ObservedObject var taskNotificationHandler: TaskNotificationHandler
    @ObservedObject var workspaceSettings: CEWorkspaceSettings
    @ObservedObject var taskManager: TaskManager

    init(
        workspaceFileManager: CEWorkspaceFileManager?,
        workspaceSettings: CEWorkspaceSettings,
        taskNotificationHandler: TaskNotificationHandler,
        taskManager: TaskManager
    ) {
        self.workspaceFileManager = workspaceFileManager
        self.workspaceSettings = workspaceSettings
        self.taskNotificationHandler = taskNotificationHandler
        self.taskManager = taskManager
    }
    var body: some View {
            HStack {
                HStack(spacing: 0) {
                    SchemeDropDownMenuView(
                        projectSettings: projectSettings,
                        tasksSettings: tasksSettings,
                        workspaceFileManager: workspaceFileManager
                    )

                    TasksDropDownMenuView(
                        projectSettings: projectSettings,
                        tasksSettings: tasksSettings,
                        taskManager: taskManager
                    )

                    Spacer()

                    TaskNotificationView(taskNotificationHandler: taskNotificationHandler)
                }
                .padding(.horizontal, 10)
                .background {
                    if colorScheme == .dark {
                        RoundedRectangle(cornerRadius: 5)
                            .opacity(0.10)
                    } else {
                        RoundedRectangle(cornerRadius: 5)
                            .opacity(0.1)
                    }
                }
                .frame(minWidth: 200, idealWidth: 680)
            }
            .frame(height: 22)
            .onReceive(workspaceSettings.$preferences.eraseToAnyPublisher()) { workspaceSettings in
                projectSettings = workspaceSettings.project
                tasksSettings = workspaceSettings.tasks
            }
            .onAppear {
                projectSettings = workspaceSettings.preferences.project
                tasksSettings = workspaceSettings.preferences.tasks
            }
    }
}
