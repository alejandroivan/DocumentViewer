//
//  ImageDocumentWorkerProtocol.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation

public protocol ImageDocumentWorkerProtocol {

    func fetchDocument(
        url: URL,
        completion: @escaping (
            _ data: UIImage?,
            _ state: DocumentState
        ) -> Void
    )

    func fetchDocument(
        base64 contents: String,
        completion: @escaping (
            _ data: UIImage?,
            _ state: DocumentState
        ) -> Void
    )
}
