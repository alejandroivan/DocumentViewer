//
//  UnitTestingDetector.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 21-02-23.
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
