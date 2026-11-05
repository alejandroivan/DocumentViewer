//
//  DocumentInternalDelegate.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

@MainActor
protocol DocumentInternalDelegate: AnyObject {

    func didChangeStateForDocument(_ document: Document)
}
