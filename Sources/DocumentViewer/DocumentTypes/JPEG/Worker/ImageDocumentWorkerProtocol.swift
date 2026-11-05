//
//  ImageDocumentWorkerProtocol.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation
import UIKit

public protocol ImageDocumentWorkerProtocol: Sendable {

    @concurrent
    func fetchDocument(url: URL) async throws(DocumentStateError) -> UIImage

    @concurrent
    func fetchDocument(base64: String) async throws(DocumentStateError) -> UIImage
}
