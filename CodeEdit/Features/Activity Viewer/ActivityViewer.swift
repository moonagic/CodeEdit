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

    @Service private var workspaceSettings: CEWorkspaceSettings

    @State private var projectSettings: CEWorkspaceSettingsData.ProjectSettings?
    @State private var tasksSettings: CEWorkspaceSettingsData.TasksSettings?

    @State private var isHoveringScheme: Bool = false
    @State private var isPresentedScheme: Bool = false
    @State private var isHoveringTasks: Bool = false
    @State private var isPresentedTasks: Bool = false

    @Service var taskManager: TaskManager
    private var workspaceFileManager: CEWorkspaceFileManager?

    init(
        workspaceFileManager: CEWorkspaceFileManager?
    ) {
        self.workspaceFileManager = workspaceFileManager
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

                    TaskNotificationView()
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
