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

    // MARK: - Initialization

    public init(
        reachability: DocumentViewerReachabilityProtocol = DocumentViewerReachability.shared
    ) {
        self.reachability = reachability
    }

    // MARK: - Private Methods

    private func async(
        _ closure: @escaping () -> Void = {},
        queue: DispatchQueue = DispatchQueue.global(qos: .background)
    ) {
        let work = DispatchWorkItem(block: closure)

        if !isRunningUnitTests {
            queue.async(execute: work)
        } else {
            work.perform()
        }
    }

    // MARK: - Public Methods

    public func fetchDocument(
        base64 contents: String,
        password: String?,
        completion: @escaping (
            _ pdfFile: PDFDocumentFile?,
            _ state: DocumentState
        ) -> Void
    ) {
        guard
            let data = Data(base64Encoded: contents),
            let pdfDocument = PDFDocumentFile(data: data)
        else {
            completion(nil, .invalidResource)
            return
        }

        let requiresPassword = pdfDocument.isEncrypted || pdfDocument.isLocked
        if requiresPassword {
            if !pdfDocument.unlock(withPassword: password ?? "") {
                completion(nil, .passwordProtected)
                return
            }
        } else if password != nil {
            debugLog("A password for the PDF file has been provided, but none is required.")
        }

        completion(pdfDocument, .success)
    }

    public func fetchDocument(
        url: URL,
        password: String?,
        completion: @escaping (
            _ pdfFile: PDFDocumentFile?,
            _ state: DocumentState
        ) -> Void
    ) {
        guard reachability.isConnectedToNetwork else {
            completion(nil, .noInternet)
            return
        }

        let loadDocument = {
            let pdfDocument = PDFDocumentFile(url: url) // Loads synchronously.

            guard let pdfDocument = pdfDocument else {
                let closure = {
                    completion(nil, .invalidResource)
                }
                self.async(closure, queue: .main)
                return
            }

            let requiresPassword = pdfDocument.isEncrypted || pdfDocument.isLocked
            if requiresPassword {
                if !pdfDocument.unlock(withPassword: password ?? "") {
                    let closure = {
                        completion(nil, .passwordProtected)
                    }
                    self.async(closure, queue: .main)
                    return
                }
            } else if password != nil {
                self.debugLog("A password for the PDF file has been provided, but none is required.")
            }

            let closure = {
                completion(pdfDocument, .success)
            }

            self.async(closure, queue: .main)
        }

        async(loadDocument)
    }
}
