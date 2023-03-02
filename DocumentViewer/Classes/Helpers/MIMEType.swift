//
//  MIMEType.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation

enum MimeType {

    // MARK: - Constants

    // Types should be considered *unimplemented* unless
    // commented with a specific `Document` implementation.
    enum Types: String {
        case unknown = "application/octet-stream"

        case gif = "image/gif"
        case jpeg = "image/jpeg" // ImageDocumentImplementation
        case pdf = "application/pdf" // PDFDocumentImplementation
        case plainText = "text/plain"
        case png = "image/png" // ImageDocumentImplementation
        case svg = "image/svg+xml"
        case tiff = "image/tiff"

        var `extension`: String {
            switch self {
            case .unknown: return ""

            case .gif: return Extensions.gif.rawValue
            case .jpeg: return Extensions.jpeg.rawValue
            case .pdf: return Extensions.pdf.rawValue
            case .plainText: return Extensions.plainText.rawValue
            case .png: return Extensions.png.rawValue
            case .svg: return Extensions.svg.rawValue
            case .tiff: return Extensions.tiff.rawValue
            }
        }
    }

    private enum Extensions: String {
        case gif
        case jpeg
        case pdf
        case plainText = "txt"
        case png
        case svg
        case tiff
    }

    private static let signatures: [UInt8: Types] = [
        0x25: .pdf,
        0x46: .plainText,
        0x47: .gif,
        0x49: .tiff,
        0x4D: .tiff,
        0x89: .png,
        0xFF: .jpeg,
    ]

    // MARK: - Public Methods

    public static func from(data: Data) -> Types {
        var c: UInt8 = 0
        data.copyBytes(to: &c, count: 1)
        return signatures[c] ?? Types.unknown
    }

    public static func from(base64: String) -> Types {
        guard let data = Data(base64Encoded: base64) else {
            return .unknown
        }
        return from(data: data)
    }

    public static func signature(from data: Data) -> UInt8 {
        var c: UInt8 = 0
        data.copyBytes(to: &c, count: 1)
        return c
    }
}
