//
//  UnitTestingDetector.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation

protocol UnitTestingDetector: AnyObject {

    var isRunningUnitTests: Bool { get }
}

extension UnitTestingDetector {

    var isRunningUnitTests: Bool {
        Thread.current.threadDictionary.allKeys.contains {
            ($0 as? String)?.range(of: "XCTest", options: .caseInsensitive) != nil
        }
    }
}
