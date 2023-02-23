//
//  PDFDocumentWorkerProtocol.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 20-02-23.
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
