//
//  ImageDocumentWorker.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation
import UIKit

public final class ImageDocumentWorker: ImageDocumentWorkerProtocol, DebugLogger {

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
    public func fetchDocument(base64: String) async throws(DocumentStateError) -> UIImage {
        guard let data = Data(base64Encoded: base64),
              let image = UIImage(data: data) else {
            throw .invalidResource
        }

        return image
    }

    @concurrent
    public func fetchDocument(url: URL) async throws(DocumentStateError) -> UIImage {
        guard reachability.isConnectedToNetwork else {
            throw .noInternet
        }

        let data = try? Data(contentsOf: url, options: .mappedIfSafe) // Loads synchronously.

        guard let data, let image = UIImage(data: data) else {
            throw .invalidResource
        }

        return image
    }
}
