//
//  DocumentInternalDataSource.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

protocol DocumentInternalDataSource: AnyObject {

    var delegate: DocumentInternalDelegate? { get set }
    func loadSource()
}
