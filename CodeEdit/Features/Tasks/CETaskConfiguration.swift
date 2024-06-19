//
//  CETaskConfiguration.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 17.06.24.
//

import Foundation

/// CodeEdit task that will be executed by the task manager.
struct CETask: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var name: String = ""
    var target: String = ""
    var workingDirectory: String = ""
    var command: String = ""
    var environmentVariables: [EnvironmentVariable]  = []

    var isInvalid: Bool {
        name.isEmpty ||
        command.isEmpty ||
        target.isEmpty ||
        workingDirectory.isEmpty
    }

    /// Ensures that the environment variables are exported, the shell navigates to the correct folder,
    /// and then executes the specified command.
    var fullCommand: String {
        // Export all necessary environment variables before starting the task
        let environmentVariables = environmentVariables.map {
            "export \($0.name)=\"\($0.value)\""
        }.joined(separator: " && ").appending(";")

        // Move into the specified folder if needed
        if workingDirectory.isEmpty {
            return "\(environmentVariables)\(command)"
        } else {
            return "\(environmentVariables)cd \(workingDirectory) && \(command)"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case target
        case workingDirectory
        case command
        case environmentVariables
    }

    struct EnvironmentVariable: Identifiable, Hashable, Codable {
        var id = UUID()
        var name: String = ""
        var value: String = ""

        /// Enables encoding the environment variables as a `name`:`value`pair.
        private struct CodingKeys: CodingKey {
            var stringValue: String
            var intValue: Int?

            init?(stringValue: String) {
                self.stringValue = stringValue
                self.intValue = nil
            }

            /// Required by the CodingKey protocol but not being currently used.
            init?(intValue: Int) {
                self.stringValue = "\(intValue)"
                self.intValue = intValue
            }
        }

        init() {}

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            for key in container.allKeys {
                name = key.stringValue
                value = try container.decode(String.self, forKey: key)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: CodingKeys(stringValue: name)!)
        }
    }
}