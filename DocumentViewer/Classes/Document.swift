//
//  Document.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 20-02-23.
//

import UIKit

public protocol Document: AnyObject {

    /// Defines the current state of the document.
    /// The `didSet` observer should inform the `delegate` of state changes.
    var state: DocumentState? { get }

    /// Defines the title of the document. This value cannot be empty.
    var title: String { get set }

    /// Defines the view that renders the document.
    var documentView: UIView { get }

    /// Defines the file URL to be used to share this document.
    /// This URL will be `nil` if the `state` is different than `DocumentState.success`.
    var shareURL: URL? { get }
}
