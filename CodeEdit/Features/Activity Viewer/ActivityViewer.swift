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

    @ObservedObject private var taskManager: TaskManager

    @State private var status: CETaskStatus = .stopped
    @State private var output: String = ""

    @State private var isHoveringScheme: Bool = false
    @State private var isPresentedScheme: Bool = false
    @State private var isHoveringTasks: Bool = false
    @State private var isPresentedTasks: Bool = false

    private var workspaceFileManager: CEWorkspaceFileManager?

    init(
        workspaceFileManager: CEWorkspaceFileManager?,
        taskManager: TaskManager
    ) {
        self.workspaceFileManager = workspaceFileManager
        self.taskManager = taskManager
    }
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                schemeDropDownMenu()
                tasksDropDownMenu()

                Spacer()

                TaskNotificationView()
            }
            .padding(.horizontal, 10)
            .background {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: 5)
                        .opacity(0.10)
                } else {
                    // TODO: Get the color right
                    RoundedRectangle(cornerRadius: 5)
                        .opacity(0.1)
//                        .foregroundStyle(.ultraThickMaterial)
                }
            }
            .frame(minWidth: 200, idealWidth: 680)
        }.frame(height: 22)
    }

    @ViewBuilder
    private func schemeDropDownMenu() -> some View {
        HStack(spacing: 5) {
            Image(systemName: "folder.badge.gearshape")
                .imageScale(.medium)
            Text(workspaceFileManager?.workspaceItem.fileName() ?? "")
                .font(.subheadline)

            Image(systemName: (isHoveringScheme || isPresentedScheme) ? "chevron.down" : "chevron.compact.right")
                .font((isHoveringScheme || isPresentedScheme) ? .footnote : .subheadline)
                .padding(.trailing, (isHoveringScheme || isPresentedScheme) ? 0 : 2)
                .padding(.leading, (isHoveringScheme || isPresentedScheme) ? -2.5 : 0)
                .transition(.scale)
        }
        .font(.caption)
        .padding(5)
        .background {
            if isHoveringScheme {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(.ultraThickMaterial)
            }
        }
        .onHover(perform: { hovering in
            self.isHoveringScheme = hovering
        })
        .popover(isPresented: $isPresentedScheme) {
            VStack(alignment: .leading, spacing: 0) {
                WorkspaceMenuItem(
                    workspaceFileManager: workspaceFileManager,
                    item: workspaceFileManager?.workspaceItem
                )

                Divider()
                    .padding(.vertical, 5)
                Group {
                    OptionMenuItem(label: "Add Folder..")
                    OptionMenuItem(label: "Workspace Settings...")
                }
            }
            .padding(5)
            .frame(width: 215)
        }.onTapGesture {
            self.isPresentedScheme.toggle()
        }
    }

    @ViewBuilder
    private func tasksDropDownMenu() -> some View {
        HStack(spacing: 3) {
            Image(systemName: "gearshape")
                .imageScale(.medium)
            // TODO: asdf
//            Text(taskManager.activeTask.name ?? "")
//                .font(.subheadline)

            Circle()
                .fill(status.color)
                .frame(width: 5, height: 5)

            if isHoveringTasks || isPresentedTasks {
                Image(systemName: "chevron.down")
                    .font(.footnote)
                    .transition(.scale)
            }
        }
        .font(.caption)
        .padding(.vertical, 5)
        .padding(.trailing, 5)
        .background {
            if isHoveringTasks {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(.ultraThickMaterial)
            }
        }
        .onHover(perform: { hovering in
            self.isHoveringTasks = hovering
        })
        .popover(isPresented: $isPresentedTasks) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(taskManager.getTasks(), id: \.name) { item in
                    TaskMenuItem(taskManager: taskManager, item: item)
                }

                Divider()
                    .padding(.vertical, 5)

                Group {
                    OptionMenuItem(label: "Add Task..")
                    OptionMenuItem(label: "Manage Tasks...")
                }
            }
            .padding(5)
            .frame(width: 215)
        }.onTapGesture {
            self.isPresentedTasks.toggle()
        }
    }

    struct WorkspaceMenuItem: View {
        var workspaceFileManager: CEWorkspaceFileManager?
        var item: CEWorkspaceFile?

        var body: some View {
            HStack {
                if workspaceFileManager?.workspaceItem.fileName() == item?.name {
                    Image(systemName: "checkmark")
                        .imageScale(.small)
                        .frame(width: 10)
                } else {
                    Spacer()
                        .frame(width: 18)
                }
                Image(systemName: "folder.badge.gearshape")
                    .imageScale(.medium)
                Text(item?.name ?? "")
                Spacer()
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .modifier(DropdownMenuItem())
            .onTapGesture { }
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }

    struct TaskMenuItem: View {
        @ObservedObject var taskManager: TaskManager
        var item: CETask

        var body: some View {
            // TODO: asdf
            Text("H")
//            HStack {
//                if taskManager.activeTask?.name == item.name {
//                    Image(systemName: "checkmark")
//                        .imageScale(.small)
//                        .frame(width: 10)
//                } else {
//                    Spacer()
//                        .frame(width: 18)
//                }
//                Image(systemName: "gearshape")
//                    .imageScale(.medium)
//                Text(item.name)
//                Spacer()
//                Circle()
//                    .fill(taskManager.activeTaskRun?.status.color ?? CETaskStatus.stopped.color)
//                    .frame(width: 5, height: 5)
//            }
//            .padding(.vertical, 5)
//            .padding(.horizontal, 10)
//            .modifier(DropdownMenuItem())
//            .onTapGesture {
//                self.taskManager.activeTask = item
//            }
//            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }

    struct OptionMenuItem: View {
        var label: String
        var body: some View {
            HStack {
                Text(label)
                Spacer()
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 28)
            .modifier(DropdownMenuItem())
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}

struct DropdownMenuItem: ViewModifier {
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .background(isHovering ? Color(NSColor.systemBlue) : .clear)
            .foregroundColor(isHovering ? Color(NSColor.white) : .primary)
            .onHover(perform: { hovering in
                self.isHovering = hovering
            })
    }
}
