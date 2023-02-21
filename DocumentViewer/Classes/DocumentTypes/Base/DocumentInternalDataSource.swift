//
//  DocumentInternalDataSource.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 21-02-23.
//

protocol DocumentInternalDataSource: AnyObject {

    var delegate: DocumentInternalDelegate? { get set }
    func loadSource()
}
