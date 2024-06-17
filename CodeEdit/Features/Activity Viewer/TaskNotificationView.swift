//
//  TaskNotificationView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 11.06.24.
//

import SwiftUI

struct TaskNotificationView: View {
    @StateObject var currentTasksListener = TaskNotificationListener()
    @State private var hovered: Bool = false
    @State private var isPresented: Bool = false

    var body: some View {
        if let currentTaskNotifications = currentTasksListener.currentTaskNotifications.notifications.first {
            HStack {
                Text(currentTaskNotifications.title)
                    .font(.subheadline)

                if currentTaskNotifications.isLoading {
                    SpinningRingView(
                        progress: currentTaskNotifications.percentage,
                        currentTaskCount: currentTasksListener.currentTaskNotifications.notifications.count
                    )
                    .padding(.leading, 5)
                    .frame(height: 15)
                }
            }
            .animation(.easeInOut, value: currentTaskNotifications)
            .padding(3)
            .background {
                if hovered {
                    RoundedRectangle(cornerRadius: 5)
                        .tint(.gray)
                        .foregroundStyle(.ultraThickMaterial)
                }
            }
            .onHover { isHovered in
                self.hovered = isHovered
            }
            .padding(-3)
            .popover(isPresented: $isPresented) {
                TaskNotificationsDetailView(currentTasksListener: currentTasksListener)
            }.onTapGesture {
                self.isPresented.toggle()
            }
        }
    }
}

#Preview {
    TaskNotificationView()
}
