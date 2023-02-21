//
//  DocumentViewerDelegate.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 20-02-23.
//

public protocol DocumentViewerDelegate: AnyObject {

    func didChangeStateForDocumentViewer(
        _ documentViewer: DocumentViewer
    )
}
