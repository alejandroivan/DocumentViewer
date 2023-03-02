//
//  PDFDocumentFile.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import PDFKit

public final class PDFDocumentFile: PDFDocument {

    // MARK: - Overrides

    public override var allowsCopying: Bool { false }
    public override var allowsCommenting: Bool { false }
    public override var allowsDocumentChanges: Bool { false }
    public override var allowsDocumentAssembly: Bool { false }
    public override var allowsFormFieldEntry: Bool { false }
}
