//
//  CodeEditWindowController+Toolbar.swift
//  CodeEdit
//
//  Created by Daniel Zhu on 5/10/24.
//

import AppKit
import SwiftUI

extension CodeEditWindowController {
    internal func setupToolbar() {
        let toolbar = NSToolbar(identifier: UUID().uuidString)
        toolbar.delegate = self
        toolbar.displayMode = .labelOnly
        toolbar.showsBaselineSeparator = false
        self.window?.titleVisibility = toolbarCollapsed ? .visible : .hidden
        self.window?.toolbarStyle = .unifiedCompact
        if Settings[\.general].tabBarStyle == .native {
            // Set titlebar background as transparent by default in order to
            // style the toolbar background in native tab bar style.
            self.window?.titlebarSeparatorStyle = .none
        } else {
            // In Xcode tab bar style, we use default toolbar background with
            // line separator.
            self.window?.titlebarSeparatorStyle = .automatic
        }
        self.window?.toolbar = toolbar
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleFirstSidebarItem,
            .flexibleSpace,
            .stopTaskSidebarItem,
            .startTaskSidebarItem,
            .sidebarTrackingSeparator,
            .branchPicker,
            .flexibleSpace,
            .activityViewer,
            .errors,
            .warnings,
            .flexibleSpace,
            .addSidebarItem,
            .toggleLastSidebarItem
        ]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleFirstSidebarItem,
            .sidebarTrackingSeparator,
            .flexibleSpace,
            .itemListTrackingSeparator,
            .toggleLastSidebarItem,
            .branchPicker,
            .activityViewer,
            .addSidebarItem,
            .warnings,
            .errors
        ]
    }

    func toggleToolbar() {
        toolbarCollapsed.toggle()
        updateToolbarVisibility()
    }

    private func updateToolbarVisibility() {
        if toolbarCollapsed {
            window?.titleVisibility = .visible
            window?.title = workspace?.workspaceFileManager?.folderUrl.lastPathComponent ?? "Empty"
            window?.toolbar = nil
        } else {
            window?.titleVisibility = .hidden
            setupToolbar()
        }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .itemListTrackingSeparator:
            guard let splitViewController else { return nil }

            return NSTrackingSeparatorToolbarItem(
                identifier: .itemListTrackingSeparator,
                splitView: splitViewController.splitView,
                dividerIndex: 1
            )
        case .toggleFirstSidebarItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleFirstSidebarItem)
            toolbarItem.label = "Navigator Sidebar"
            toolbarItem.paletteLabel = " Navigator Sidebar"
            toolbarItem.toolTip = "Hide or show the Navigator"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.toggleFirstPanel)
            toolbarItem.image = NSImage(
                systemSymbolName: "sidebar.leading",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))

            return toolbarItem
        case .toggleLastSidebarItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleLastSidebarItem)
            toolbarItem.label = "Inspector Sidebar"
            toolbarItem.paletteLabel = "Inspector Sidebar"
            toolbarItem.toolTip = "Hide or show the Inspectors"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.toggleLastPanel)
            toolbarItem.image = NSImage(
                systemSymbolName: "sidebar.trailing",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))

            return toolbarItem
        case .stopTaskSidebarItem:
            return toolbarItem(
                identifier: itemIdentifier,
                label: "Stop",
                tooltip: "Stop execution of task",
                icon: "stop.fill",
                action: nil
            )
        case .startTaskSidebarItem:
            return toolbarItem(
                identifier: itemIdentifier,
                label: "Start",
                tooltip: "Start execution of task",
                icon: "play.fill",
                action: #selector(self.runActiveTask)
            )
        case .addSidebarItem:
            return toolbarItem(
                identifier: itemIdentifier,
                label: "Add",
                tooltip: "Add",
                icon: "plus",
                action: nil
            )
        case .branchPicker:
            let toolbarItem = NSToolbarItem(itemIdentifier: .branchPicker)
            let view = NSHostingView(
                rootView: ToolbarBranchPicker(
                    workspaceFileManager: workspace?.workspaceFileManager
                )
            )
            toolbarItem.view = view

            return toolbarItem
        case .activityViewer:
            let toolbarItem = NSToolbarItem(itemIdentifier: .activityViewer)
            toolbarItem.view = NSHostingView(
                rootView: ActivityViewer(
                    workspaceFileManager: workspace?.workspaceFileManager,
                    taskManager: TaskManager()
                )
            )
            return toolbarItem
        case .warnings:
            let toolbarItem = NSToolbarItem(itemIdentifier: .warnings)
                let view = NSHostingView(
                    rootView: CustomToolbarItem(
                        symbolName: "exclamationmark.triangle.fill",
                        trailingText: "2",
                        color: .yellow
                    ) {
                        print("WARNINGS!")
                    }
                )
            toolbarItem.view = view

            return toolbarItem
        case .errors:
            let toolbarItem = NSToolbarItem(itemIdentifier: .errors)
                let view = NSHostingView(
                    rootView: CustomToolbarItem(
                        symbolName: "xmark.octagon.fill",
                        trailingText: "5",
                        color: .red
                    ) {
                        print("ERRORS!")
                    }
                )
            toolbarItem.view = view

            return toolbarItem
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }

    private func toolbarItem(
        identifier: NSToolbarItem.Identifier,
        label: String,
        tooltip: String,
        icon: String,
        action: Selector?
    ) -> NSToolbarItem {
        let toolbarItem = NSToolbarItem(itemIdentifier: identifier)
        toolbarItem.label = label
        toolbarItem.paletteLabel = label
        toolbarItem.toolTip = tooltip
        toolbarItem.isBordered = true
        toolbarItem.target = self
        toolbarItem.action = action
        toolbarItem.image = NSImage(
            systemSymbolName: icon,
            accessibilityDescription: nil
        )?.withSymbolConfiguration(.init(scale: .large))

        return toolbarItem
    }

    @objc
    private func runActiveTask() {
        print("RUNNING TASK")
        taskManager.executeActiveTask()
    }
}

struct CustomToolbarItem: View {
    var symbolName: String
    var trailingText: String
    var color: Color
    var action: () -> Void

    var body: some View {
        HStack(spacing: 1) {
            Image(systemName: symbolName)
                .foregroundStyle(.white, color)
                .font(.footnote)

            Text(trailingText)
                .foregroundStyle(.secondary)
                .font(.footnote)
                .bold()
        }
        .modifier(HoverViewModifier())
        .onTapGesture {
            action()
        }
    }
}

struct HoverViewModifier: ViewModifier {
    @State private var hovered = false
    func body(content: Content) -> some View {
        content
            .padding(5)
            .background {
                if hovered {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(.ultraThickMaterial)
                }
            }
            .onHover { isHovered in
                self.hovered = isHovered
            }
    }
}

#Preview {
    CustomToolbarItem(
        symbolName: "xmark.octagon.fill",
        trailingText: "3",
        color: .red
    ) {
        print("HELLO")
    }.padding()
}
