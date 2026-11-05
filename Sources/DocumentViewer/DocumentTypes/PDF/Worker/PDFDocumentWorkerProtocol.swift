//
//  PDFDocumentWorkerProtocol.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation

public protocol PDFDocumentWorkerProtocol: Sendable {

    @concurrent
    func fetchDocument(
        url: URL,
        password: String?
    ) async throws(DocumentStateError) -> PDFDocumentFile

    @concurrent
    func fetchDocument(
        base64: String,
        password: String?
    ) async throws(DocumentStateError) -> PDFDocumentFile
}
