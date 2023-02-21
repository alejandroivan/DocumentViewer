//
//  DocumentSource.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 20-02-23.
//

import Foundation

public enum DocumentSource {
    case base64(_ contents: String?)
    case url(_ url: URL?)
}
