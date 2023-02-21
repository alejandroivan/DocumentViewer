//
//  AKDocumentTypePDFFile.swift
//
//  Copyright © 2023 Banco de Crédito e Inversiones. All rights reserved.
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
