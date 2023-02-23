//
//  ImageDocumentWorker.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 22-02-23.
//

import Foundation

public final class ImageDocumentWorker: ImageDocumentWorkerProtocol, UnitTestingDetector, DebugLogger {

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
        completion: @escaping (
            _ data: UIImage?,
            _ state: DocumentState
        ) -> Void
    ) {
        guard
            let data = Data(base64Encoded: contents),
            let image = UIImage(data: data)
        else {
            completion(nil, .invalidResource)
            return
        }
        completion(image, .success)
    }

    public func fetchDocument(
        url: URL,
        completion: @escaping (
            _ data: UIImage?,
            _ state: DocumentState
        ) -> Void
    ) {
        guard reachability.isConnectedToNetwork else {
            completion(nil, .noInternet)
            return
        }

        let loadDocument = {
            let data = try? Data(contentsOf: url, options: .mappedIfSafe) // Loads synchronously.

            guard
                let data = data,
                let image = UIImage(data: data)
            else {
                let closure = {
                    completion(nil, .invalidResource)
                }
                self.async(closure, queue: .main)
                return
            }

            let closure = {
                completion(image, .success)
            }
            self.async(closure, queue: .main)
        }

        async(loadDocument)
    }
}
