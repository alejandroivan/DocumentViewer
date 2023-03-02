//
//  DebugLogger.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation

protocol DebugLogger {

    /// Allows the user to print messages to the Xcode debugger.
    /// Works the same as `print()`, but only prints if the `DEBUG` macro is `1`.
    func debugLog(
        _ items: Any...,
        separator: String,
        terminator: String
    )
}

extension DebugLogger {

    func debugLog(
        _ items: Any...,
        separator: String = " ",
        terminator: String = "\n"
    ) {
        #if targetEnvironment(simulator) && DEBUG
        let prefixes = [
            "[\(String(describing: self))]"
        ]
        print(prefixes + items, separator: separator, terminator: terminator)
        #endif
    }
}
