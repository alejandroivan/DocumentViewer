//
//  PDFDocumentWorker.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation

public final class PDFDocumentWorker: PDFDocumentWorkerProtocol, DebugLogger {

    // MARK: - Private Properties

    private let reachability: any DocumentViewerReachabilityProtocol

    // MARK: - Initialization

    public init(
        reachability: any DocumentViewerReachabilityProtocol = DocumentViewerReachability.shared
    ) {
        self.reachability = reachability
    }

    // MARK: - Public Methods

    @concurrent
    public func fetchDocument(
        base64: String,
        password: String?
    ) async throws(DocumentStateError) -> PDFDocumentFile {
        guard
            let data = Data(base64Encoded: base64),
            let pdfDocument = PDFDocumentFile(data: data) else {
            throw .invalidResource
        }

        if let password {
            try unlock(pdfDocument, password: password)
        }

        return pdfDocument
    }

    @concurrent
    public func fetchDocument(
        url: URL,
        password: String? = nil
    ) async throws(DocumentStateError) -> PDFDocumentFile {
        guard reachability.isConnectedToNetwork else {
            throw .noInternet
        }

        guard let pdfDocument = PDFDocumentFile(url: url) else {
            throw .invalidResource
        }

        if let password {
            try unlock(pdfDocument, password: password )
        }

        return pdfDocument
    }

    private func unlock(
        _ pdfDocument: PDFDocumentFile,
        password: String
    ) throws(DocumentStateError) {
        let requiresPassword = pdfDocument.isEncrypted || pdfDocument.isLocked
        if requiresPassword {
            guard pdfDocument.unlock(withPassword: password) else {
                throw .passwordProtected
            }
        } else if !password.isEmpty {
            log("A password for the PDF file has been provided, but none is required.")
        }
    }
}
