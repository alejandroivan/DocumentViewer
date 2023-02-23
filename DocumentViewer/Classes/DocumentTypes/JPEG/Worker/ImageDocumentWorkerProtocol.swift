//
//  ImageDocumentWorkerProtocol.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 22-02-23.
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
