//
//  DocumentSource.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation

public enum DocumentSource {
    case base64(_ contents: String?)
    case url(_ url: URL?)
}
