//
//  Shells.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 13.06.24.
//

import Foundation

public enum Shell: String {
    case bash = "/bin/bash"
    case zsh = "/bin/zsh"
    // swiftlint:disable:next identifier_name
    case sh = "/bin/sh"
    case csh = "/bin/csh"
    case tcsh = "/bin/tcsh"
    case ksh = "/bin/ksh"

    var url: String {
        return self.rawValue
    }

    // swiftlint:disable function_body_length
    @discardableResult
    public static func executeCommandWithShell(
        process: Process,
        command: String,
        shell: Shell = .bash,
        outputPipe: Pipe
    ) throws -> String {
        // Set the executable to bash
        process.executableURL = URL(fileURLWithPath: shell.url)
        // Pass the command as an argument to bash
        // `--login` argument is needed when using a shell with a process in Swift to ensure
        // that the shell loads the user's profile settings (like .bash_profile or .profile),
        // which configure the environment variables and other shell settings.
        process.arguments = ["--login", "-c", command]

        // Create a queue to handle output data
        let outputDataQueue = DispatchQueue(label: "bash-output-queue")

        process.standardOutput = outputPipe
        process.standardError = outputPipe

        // Handle readability for command output
//        commandOutputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
//            let data = fileHandle.availableData
//            outputDataQueue.async {
//                commandOutputData.append(data)
//                outputHandler?.write(data)
//                if let outputString = String(data: data, encoding: .utf8), !outputString.isEmpty {
//                    print("OUTPUT: \(outputString)")
//                }
//            }
//        }

        // Handle readability for command error
//        commandErrorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
//            let data = fileHandle.availableData
//            outputDataQueue.async {
//                commandErrorData.append(data)
//                outputHandler?.write(data)
//                if let outputString = String(data: data, encoding: .utf8), !outputString.isEmpty {
//                    print("ERROR: \(outputString)")
//                }
//            }
//        }

        // Run the process
        try process.run()

        // Wait for the process to exit
        process.waitUntilExit()

        // Remove the readability handlers
        outputPipe.fileHandleForReading.readabilityHandler = nil

        // Return the command output or throw an error if the process terminated with a non-zero status
        return outputDataQueue.sync {
            if process.terminationStatus != 0 {
                return "\(process.terminationStatus)"
            }
            return ""
        }
    }
    // swiftlint:enable function_body_length
}
