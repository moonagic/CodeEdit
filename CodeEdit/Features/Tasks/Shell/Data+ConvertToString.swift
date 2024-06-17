//
//  Data+ConvertToString.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 13.06.24.
//

import Foundation

extension Data {
    func convertToString() -> String {
        guard let outputString = String(data: self, encoding: .utf8) else {
            return ""
        }

        guard !outputString.hasSuffix("\n") else {
            let endIndex = outputString.index(before: outputString.endIndex)
            return String(outputString[..<endIndex])
        }

        return outputString
    }
}
