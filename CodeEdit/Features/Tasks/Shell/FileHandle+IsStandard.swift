//
//  FileHandle+IsStandard.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 13.06.24.
//

import Foundation

extension FileHandle {
    var isStandardFileHandle: Bool {
        return self === FileHandle.standardOutput ||
        self === FileHandle.standardError ||
        self === FileHandle.standardInput
    }
}
