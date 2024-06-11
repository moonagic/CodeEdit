//
//  RunningTask.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 10.06.24.
//

import Foundation

/// Represents a notifications or tasks, that are displayed in the activity viewer
struct NotificationModel: Equatable {
    var id: String
    var title: String
    var message: String?
    var percentage: Double?
    var isLoading: Bool = false
}
