//
//  NavigatorAreaView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct NavigatorAreaView: View {
    @ObservedObject private var workspace: WorkspaceDocument
    @ObservedObject private var extensionManager = ExtensionManager.shared
    @ObservedObject public var viewModel: NavigatorSidebarViewModel

    @AppSettings(\.general.navigatorTabBarPosition)
    var sidebarPosition: SettingsData.SidebarTabBarPosition

    init(workspace: WorkspaceDocument, viewModel: NavigatorSidebarViewModel) {
        self.workspace = workspace
        self.viewModel = viewModel

        viewModel.tabItems = [.project, .sourceControl, .search] +
        extensionManager
            .extensions
            .map { ext in
                ext.availableFeatures.compactMap {
                    if case .sidebarItem(let data) = $0, data.kind == .navigator {
                        return NavigatorTab.uiExtension(endpoint: ext.endpoint, data: data)
                    }
                    return nil
                }
            }
            .joined()
    }

    @State var items = [NavigatorTab.project, .search, .sourceControl]
    
    var body: some View {
        Group {
            if items.isEmpty {
                Text("Tab not found")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: .zero) {
                    Divider()
                    BasicTabView(selection: $viewModel.selectedTab, tabPosition: sidebarPosition) {
                        Text("Hello")
                            .tabTitle("Title")
                            .tabIcon(Image(systemName: "square.and.arrow.up"))
                            .tag("Test")
                        ForEach([0, 1], id: \.self) { _ in
                            ForEach(items) { item in
                                let image = if item.systemImage == "vault" {
                                    Image(symbol: "vault")
                                } else {
                                    Image(systemName: item.systemImage)
                                }
                                item
                                    .tabTitle(item.title)
                                    .tabIcon(image)
                                    .tag(item)
                            }
                            .onMove { indexset, index in
                                items.move(fromOffsets: indexset, toOffset: index)
                            }
                            
                        }
                        Text("Hello2")
                            .tabTitle("Title")
                            .tabIcon(Image(systemName: "square.and.arrow.down"))
                            .tag("Test2")
                    }
                }
            }
        }
        
//        .safeAreaInset(edge: .leading, spacing: 0) {
//            if sidebarPosition == .side {
//                HStack(spacing: 0) {
//                    AreaTabBar(items: $viewModel.tabItems, selection: $viewModel.selectedTab, position: sidebarPosition)
//                    Divider()
//                }
//            }
//        }
//        .safeAreaInset(edge: .top, spacing: 0) {
//            if sidebarPosition == .top {
//                VStack(spacing: 0) {
//                    Divider()
//                    AreaTabBar(items: $viewModel.tabItems, selection: $viewModel.selectedTab, position: sidebarPosition)
//                    Divider()
//                }
//            } else {
//                Divider()
//            }
//        }
        .environmentObject(workspace)
    }
}
