//
//  ImageDocumentImplementation.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 22-02-23.
//

import Foundation
import UIKit

public final class ImageDocumentImplementation: Document, DocumentInternalDataSource, UnitTestingDetector {

    // MARK: - Constants

    private enum LocalConstants {
        static let sharePathSuffix = "image-file"

        /// Defines the compression quality of the preview file to be
        /// generated to share this document. It should be 1 if we don't
        /// want to lose quality.
        static let shareCompressionQuality: CGFloat = 1
    }

    // MARK: - Public Properties

    public var state: DocumentState? {
        didSet {
            delegate?.didChangeStateForDocument(self)
        }
    }

    public var title: String

    public let documentView: UIView = ImageDocumentView()

    public var shareURL: URL? {
        calculateShareURL()
    }

    public private(set) var source: DocumentSource

    // MARK: - Internal Properties

    weak var delegate: DocumentInternalDelegate?

    // MARK: - Private Properties

    private let worker: ImageDocumentWorkerProtocol

    private var imageDocumentView: ImageDocumentView? {
        documentView as? ImageDocumentView
    }

    // MARK: - Initialization

    public init(
        title: String,
        source: DocumentSource,
        worker: ImageDocumentWorkerProtocol = ImageDocumentWorker()
    ) {
        assert(!title.isEmpty, "The `title` for the `ImageDocumentImplementation` instance cannot be empty.")
        self.title = title
        self.source = source
        self.worker = worker
    }

    // MARK: - Private Methods

    // MARK: Data Handling

    private func handleBase64(_ base64: String?) {
        state = .loading

        guard let base64 = base64 else {
            state = .invalidResource
            return
        }

        worker.fetchDocument(base64: base64) { image, state in
            guard let image = image else {
                self.state = .invalidResource
                return
            }

            self.imageDocumentView?.image = image
            self.state = state
        }
    }

    private func handleURL(_ url: URL?) {
        state = .loading

        guard let url = url else {
            state = .invalidResource
            return
        }

        worker.fetchDocument(url: url) { image, state in
            guard let image = image else {
                self.state = .invalidResource
                return
            }

            self.imageDocumentView?.image = image
            self.state = state
        }
    }

    private func calculateShareURL() -> URL? {
        var data: Data?

        if hasAlphaChannel(image: imageDocumentView?.image) {
            data = imageDocumentView?.image?.pngData()
        } else {
            data = imageDocumentView?.image?.jpegData(compressionQuality: LocalConstants.shareCompressionQuality)
        }

        guard let data = data else {
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

    private func hasAlphaChannel(image: UIImage?) -> Bool {
        let alphaInfo: CGImageAlphaInfo = image?.cgImage?.alphaInfo ?? .none
        let noAlpha: [CGImageAlphaInfo] = [.none, .noneSkipFirst, .noneSkipLast]
        return !noAlpha.contains(alphaInfo)
    }

    // MARK: - Internal Methods

    func loadSource() {
        switch source {
        case .base64(let base64):
            handleBase64(base64)
        case .url(let url):
            handleURL(url)
        }
    }
}
