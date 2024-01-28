//
//  ImageDocumentWorker.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation

public final class ImageDocumentWorker: ImageDocumentWorkerProtocol, UnitTestingDetector, DebugLogger {

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
        completion: @escaping (ResultType) -> Void
    ) {
        guard
            let data = Data(base64Encoded: contents),
            let image = UIImage(data: data)
        else {
            completion(.failure(.invalidResource))
            return
        }
        completion(.success(image))
    }

    public func fetchDocument(
        url: URL,
        completion: @escaping (ResultType) -> Void
    ) {
        guard reachability.isConnectedToNetwork else {
            completion(.failure(.noInternet))
            return
        }

        let loadDocument = { [weak self] in
            let data = try? Data(contentsOf: url, options: .mappedIfSafe) // Loads synchronously.

            guard
                let data = data,
                let image = UIImage(data: data)
            else {
                let closure = {
                    completion(.failure(.invalidResource))
                }
                self?.mainQueue.asyncTestable(closure: closure)
                return
            }

            let closure = {
                completion(.success(image))
            }
            self?.mainQueue.asyncTestable(closure: closure)
        }

        backgroundQueue.asyncTestable(closure: loadDocument)
    }
}
