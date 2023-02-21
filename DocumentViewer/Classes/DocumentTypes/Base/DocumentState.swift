//
//  DocumentState.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 20-02-23.
//

public enum DocumentState: Error {
    case loading
    case success
    case invalidResource
    case noInternet
    case passwordProtected
}
