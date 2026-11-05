//
//  PDFDocumentImplementation.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation
import PDFKit

public final class PDFDocumentImplementation: Document, DocumentInternalDataSource, UnitTestingDetector {

    // MARK: - Constants

    private enum LocalConstants {
        static let sharePathSuffix = "pdf-file"
    }

    // MARK: - Public Properties

    public var password: String?

    public private(set) var source: DocumentSource

    public var title: String

    public let documentView: UIView = PDFDocumentView()

    public var shareURL: URL? {
        calculateShareURL()
    }

    public private(set) var state: DocumentState? {
        didSet {
            delegate?.didChangeStateForDocument(self)
        }
    }

    // MARK: - Internal Properties
    
    weak var delegate: DocumentInternalDelegate?

    // MARK: - Private Properties

    private let worker: PDFDocumentWorkerProtocol
    private let mainQueue = DispatchQueue.main

    private var pdfView: PDFDocumentView? {
        documentView as? PDFDocumentView
    }

    // MARK: - Initialization

    public init(
        title: String,
        source: DocumentSource,
        password: String? = nil,
        worker: PDFDocumentWorkerProtocol = PDFDocumentWorker()
    ) {
        assert(!title.isEmpty, "The `title` for the `PDFDocumentImplementation` instance cannot be empty.")
        self.password = password
        self.source = source
        self.title = title
        self.worker = worker
    }

    // MARK: - Private Methods

    private func handleBase64(_ base64: String?) async {
        state = .loading

        guard
            let base64 = base64,
            MimeType.from(base64: base64) == .pdf
        else {
            state = .failure(.invalidResource)
            return
        }

        do {
            let document = try await worker.fetchDocument(base64: base64, password: password)
            pdfView?.document = document
            state = .success
        } catch {
            state = .failure(error)
        }
    }

    private func handleURL(_ url: URL?) async {
        state = .loading

        guard let url = url else {
            state = .failure(.invalidResource)
            return
        }

        do {
            let document = try await worker.fetchDocument(url: url, password: password)
            pdfView?.document = document
            state = .success
        } catch {
            state = .failure(error)
        }
    }

    private func calculateShareURL() -> URL? {
        guard let data = pdfView?.document?.dataRepresentation() else {
            return nil
        }

        let temporaryDirectory = FileManager
            .default
            .temporaryDirectory
            .appendingPathComponent(LocalConstants.sharePathSuffix)

        let fileExtension = MimeType.from(data: data).extension
        let fileName = "\(title).\(fileExtension)"
        let filePath = temporaryDirectory.appendingPathComponent(fileName)

        if !FileManager.default.fileExists(atPath: temporaryDirectory.absoluteString) {
            try? FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        }

        if FileManager.default.fileExists(atPath: filePath.absoluteString) {
            try? FileManager.default.removeItem(at: filePath)
        }

        do {
            try data.write(to: filePath, options: [.atomic, .completeFileProtection])
            return filePath
        } catch {
            return nil
        }
    }

    // MARK: - Internal Methods

    func loadSource() async {
        switch source {
        case .base64(let base64): await handleBase64(base64)
        case .url(let url): await handleURL(url)
        }
    }
}
