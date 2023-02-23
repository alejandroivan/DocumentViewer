//
//  MIMETypeDetector.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 22-02-23.
//

import Foundation

enum MimeType {

    // MARK: - Constants

    enum Types: String {
        case unknown = "application/octet-stream"

        case gif = "image/gif"
        case jpeg = "image/jpeg"
        case pdf = "application/pdf"
        case png = "image/png"
        case tiff = "image/tiff"

        var `extension`: String {
            switch self {
            case .unknown: return ""

            case .gif: return Extensions.gif.rawValue
            case .jpeg: return Extensions.jpeg.rawValue
            case .pdf: return Extensions.pdf.rawValue
            case .png: return Extensions.png.rawValue
            case .tiff: return Extensions.tiff.rawValue
            }
        }
    }

    private enum Extensions: String {
        case gif
        case jpeg
        case pdf
        case png
        case tiff
    }

    private static let signatures: [UInt8: Types] = [
        0x25: .pdf,
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
}
