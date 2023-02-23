//
//  DocumentViewerDelegate.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 20-02-23.
//

@objc
public protocol DocumentViewerDelegate: AnyObject {

    @objc
    optional func didChangeStateForDocumentViewer(
        _ documentViewer: DocumentViewer
    )

    @objc
    optional func didFinishDismissingDocumentViewer(
        _ documentViewer: DocumentViewer
    )
}
