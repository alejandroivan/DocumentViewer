//
//  PDFDocumentWorkerProtocol.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation

public protocol PDFDocumentWorkerProtocol {

    func fetchDocument(
        url: URL,
        password: String?,
        completion: @escaping (
            _ pdfFile: PDFDocumentFile?,
            _ state: DocumentState
        ) -> Void
    )

    func fetchDocument(
        base64 contents: String,
        password: String?,
        completion: @escaping (
            _ pdfFile: PDFDocumentFile?,
            _ state: DocumentState
        ) -> Void
    )
}
