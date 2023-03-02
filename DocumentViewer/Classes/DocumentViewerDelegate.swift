//
//  DocumentViewerDelegate.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

@objc
public protocol DocumentViewerDelegate: AnyObject {

    @objc
    optional func didChangeStateForDocumentViewer(
        _ documentViewer: DocumentViewer
    )

    @objc
    optional func documentViewer(
        _ documentViewer: DocumentViewer,
        didFinishPresenting navigationType: DocumentViewerNavigationType
    )
}
