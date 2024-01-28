//
//  PDFDocumentWorker.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation

public final class PDFDocumentWorker: PDFDocumentWorkerProtocol, UnitTestingDetector, DebugLogger {

    // MARK: - Private Properties

    private let reachability: DocumentViewerReachabilityProtocol
    private lazy var backgroundQueue = DispatchQueue.global(qos: .background)
    private lazy var mainQueue = DispatchQueue.main

    // MARK: - Initialization

    public init(
        reachability: DocumentViewerReachabilityProtocol = DocumentViewerReachability.shared
    ) {
        self.reachability = reachability
    }

    // MARK: - Public Methods

    public func fetchDocument(
        base64 contents: String,
        password: String?,
        completion: @escaping (ResultType) -> Void
    ) {
        guard
            let data = Data(base64Encoded: contents),
            let pdfDocument = PDFDocumentFile(data: data)
        else {
            completion(.failure(.invalidResource))
            return
        }

        let requiresPassword = pdfDocument.isEncrypted || pdfDocument.isLocked
        if requiresPassword {
            if !pdfDocument.unlock(withPassword: password ?? "") {
                completion(.failure(.passwordProtected))
                return
            }
        } else if password != nil {
            log("A password for the PDF file has been provided, but none is required.")
        }

        completion(.success(pdfDocument))
    }

    public func fetchDocument(
        url: URL,
        password: String?,
        completion: @escaping (ResultType) -> Void
    ) {
        guard reachability.isConnectedToNetwork else {
            completion(.failure(.noInternet))
            return
        }

        let loadDocument = { [weak self] in
            let pdfDocument = PDFDocumentFile(url: url) // Loads synchronously.

            guard let pdfDocument = pdfDocument else {
                let closure = {
                    completion(.failure(.invalidResource))
                }
                self?.mainQueue.async(execute: closure)
                return
            }

            let requiresPassword = pdfDocument.isEncrypted || pdfDocument.isLocked
            if requiresPassword {
                if !pdfDocument.unlock(withPassword: password ?? "") {
                    let closure = {
                        completion(.failure(.passwordProtected))
                    }
                    self?.mainQueue.async(execute: closure)
                    return
                }
            } else if password != nil {
                self?.log("A password for the PDF file has been provided, but none is required.")
            }

            let closure = {
                completion(.success(pdfDocument))
            }

            self?.mainQueue.async(execute: closure)
        }

        backgroundQueue.async(execute: loadDocument)
    }
}
