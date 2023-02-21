//
//  DocumentDelegate.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 20-02-23.
//

protocol DocumentInternalDelegate: AnyObject {

    func didChangeStateForDocument(_ document: Document)
}
