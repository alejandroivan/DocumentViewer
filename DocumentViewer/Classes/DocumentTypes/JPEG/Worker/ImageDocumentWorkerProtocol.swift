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

    typealias ResultType = Result<UIImage, DocumentState>

    func fetchDocument(
        url: URL,
        completion: @escaping (ResultType) -> Void
    )

    func fetchDocument(
        base64 contents: String,
        completion: @escaping (ResultType) -> Void
    )
}
