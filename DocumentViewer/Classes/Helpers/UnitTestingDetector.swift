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
        NSClassFromString("XCTest") != nil
    }
}
