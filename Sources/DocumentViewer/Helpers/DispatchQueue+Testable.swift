//
//  DispatchQueue+Testable.swift
//  DocumentViewer
//
//  Copyright © 2024 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation

extension DispatchQueue: UnitTestingDetector {

    func asyncTestable(
        closure: @escaping @convention(block) () -> Void
    ) {
        let workItem = DispatchWorkItem(block: closure)
        asyncTestable(execute: workItem)
    }

    func asyncTestable(
        execute workItem: DispatchWorkItem
    ) {
        if !isRunningUnitTests {
            async(execute: workItem)
        } else {
            workItem.perform()
        }
    }
}

public func asyncTestable(
    on queue: DispatchQueue = DispatchQueue.main,
    execute workItem: DispatchWorkItem
) {
    queue.asyncTestable(execute: workItem)
}

public func asyncTestable(
    on queue: DispatchQueue = DispatchQueue.main,
    closure: @escaping @convention(block) () -> Void
) {
    queue.asyncTestable(closure: closure)
}
