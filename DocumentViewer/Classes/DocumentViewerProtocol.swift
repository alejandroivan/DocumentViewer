//
//  DocumentViewerProtocol.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 22-02-23.
//

import UIKit

public protocol DocumentViewerProtocol: AnyObject {

    var document: Document? { get set }
    var state: DocumentState? { get }
    var shareURL: URL? { get }

    var delegate: DocumentViewerDelegate? { get set }

    var title: String? { get set }

    var headerView: UIView? { get set }
    var footerView: UIView? { get set }

    func showActivityIndicator()
    func hideActivityIndicator()
}
