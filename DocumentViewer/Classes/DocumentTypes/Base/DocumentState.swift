//
//  DocumentState.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

public enum DocumentState: Error {
    case loading
    case success
    case invalidResource
    case noInternet
    case passwordProtected
}
