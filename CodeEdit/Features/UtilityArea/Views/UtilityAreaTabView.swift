//
//  UtilityAreaTabView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/30/23.
//

import SwiftUI

struct UtilityAreaTabView<Content: View, LeadingSidebar: View, TrailingSidebar: View>: View {
    @ObservedObject var utilityAreaTabViewModel: UtilityAreaTabViewModel

    let content: (UtilityAreaTabViewModel) -> Content
    let leadingSidebar: (UtilityAreaTabViewModel) -> LeadingSidebar?
    let trailingSidebar: (UtilityAreaTabViewModel) -> TrailingSidebar?

    let hasLeadingSidebar: Bool
    let hasTrailingSidebar: Bool

    init(
        model: UtilityAreaTabViewModel,
        @ViewBuilder content: @escaping (UtilityAreaTabViewModel) -> Content,
        @ViewBuilder leadingSidebar: @escaping (UtilityAreaTabViewModel) -> LeadingSidebar,
        @ViewBuilder trailingSidebar: @escaping (UtilityAreaTabViewModel) -> TrailingSidebar,
        hasLeadingSidebar: Bool = true,
        hasTrailingSidebar: Bool = true
    ) {
        self.utilityAreaTabViewModel = model

        self.content = content
        self.leadingSidebar = leadingSidebar
        self.trailingSidebar = trailingSidebar

        self.hasLeadingSidebar = hasLeadingSidebar
        self.hasTrailingSidebar = hasTrailingSidebar
    }

    init(
        model: UtilityAreaTabViewModel,
        @ViewBuilder content: @escaping (UtilityAreaTabViewModel) -> Content
    ) where
        LeadingSidebar == EmptyView,
        TrailingSidebar == EmptyView {
        self.init(
            model: model,
            content: content,
            leadingSidebar: { _ in EmptyView() },
            trailingSidebar: { _ in EmptyView() },
            hasLeadingSidebar: false,
            hasTrailingSidebar: false
        )
    }

    init(
        model: UtilityAreaTabViewModel,
        @ViewBuilder content: @escaping (UtilityAreaTabViewModel) -> Content,
        @ViewBuilder leadingSidebar: @escaping (UtilityAreaTabViewModel) -> LeadingSidebar
    ) where TrailingSidebar == EmptyView {
        self.init(
            model: model,
            content: content,
            leadingSidebar: leadingSidebar,
            trailingSidebar: { _ in EmptyView() },
            hasTrailingSidebar: false
        )
    }

    init(
        model: UtilityAreaTabViewModel,
        @ViewBuilder content: @escaping (UtilityAreaTabViewModel) -> Content,
        @ViewBuilder trailingSidebar: @escaping (UtilityAreaTabViewModel) -> TrailingSidebar
    ) where LeadingSidebar == EmptyView {
        self.init(
            model: model,
            content: content,
            leadingSidebar: { _ in EmptyView() },
            trailingSidebar: trailingSidebar,
            hasLeadingSidebar: false
        )
    }

    var body: some View {
        SplitView(axis: .horizontal) {
            // Leading Sidebar
            if utilityAreaTabViewModel.hasLeadingSidebar {
                leadingSidebar(utilityAreaTabViewModel)
                    .collapsable()
                    .collapsed($utilityAreaTabViewModel.leadingSidebarIsCollapsed)
                    .frame(minWidth: 200, idealWidth: 240, maxWidth: 400)
                    .environment(\.paneArea, .leading)
            }

            // Content Area
            content(utilityAreaTabViewModel)
                .holdingPriority(.init(1))
                .environment(\.paneArea, .main)

            // Trailing Sidebar
            if utilityAreaTabViewModel.hasTrailingSidebar {
                trailingSidebar(utilityAreaTabViewModel)
                    .collapsable()
                    .collapsed($utilityAreaTabViewModel.trailingSidebarIsCollapsed)
                    .frame(minWidth: 200, idealWidth: 240, maxWidth: 400)
                    .environment(\.paneArea, .trailing)
            }
        }
        .animation(.default, value: utilityAreaTabViewModel.leadingSidebarIsCollapsed)
        .animation(.default, value: utilityAreaTabViewModel.trailingSidebarIsCollapsed)
        .frame(maxHeight: .infinity)
        .overlay(alignment: .bottomLeading) {
            if utilityAreaTabViewModel.hasLeadingSidebar {
                PaneToolbar {
                    PaneToolbarSection {
                        Button {
                            utilityAreaTabViewModel.leadingSidebarIsCollapsed.toggle()
                        } label: {
                            Image(systemName: "square.leadingthird.inset.filled")
                        }
                        .buttonStyle(.icon(isActive: !utilityAreaTabViewModel.leadingSidebarIsCollapsed))
                    }
                    Divider()
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if utilityAreaTabViewModel.hasTrailingSidebar {
                PaneToolbar {
                    Divider()
                    PaneToolbarSection {
                        Button {
                            utilityAreaTabViewModel.trailingSidebarIsCollapsed.toggle()
                        } label: {
                            Image(systemName: "square.trailingthird.inset.filled")
                        }
                        .buttonStyle(.icon(isActive: !utilityAreaTabViewModel.trailingSidebarIsCollapsed))
                        Spacer()
                            .frame(width: 24)
                    }
                }
            }
        }
        .environmentObject(utilityAreaTabViewModel)
        .onAppear {
            utilityAreaTabViewModel.hasLeadingSidebar = hasLeadingSidebar
            utilityAreaTabViewModel.hasTrailingSidebar = hasTrailingSidebar
        }
    }
}

enum PaneArea: String {
    case leading
    case main
    case mainLeading
    case mainCenter
    case mainTrailing
    case trailing
}

private struct PaneAreaKey: EnvironmentKey {
    static let defaultValue: PaneArea? = nil
}

extension EnvironmentValues {
    var paneArea: PaneArea? {
        get { self[PaneAreaKey.self] }
        set { self[PaneAreaKey.self] = newValue }
    }
}

struct PaneToolbarSection<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        HStack(spacing: 0) {
            content
        }
    }
}
