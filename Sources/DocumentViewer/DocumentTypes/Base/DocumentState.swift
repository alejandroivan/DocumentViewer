//
//  DocumentState.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

public enum DocumentState: Sendable {
    case failure(_ error: DocumentStateError)
    case loading
    case success
}

public enum DocumentStateError: Error, Sendable {
    case invalidResource
    case noInternet
    case passwordProtected
}
