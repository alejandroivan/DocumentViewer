//
//  PDFDocumentView.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import UIKit
import PDFKit

public final class PDFDocumentView: PDFView {

    // MARK: - Constants

    private enum LocalConstants {

        /// This `maxScaleFactor` is defined as N times the `scaleFactorForSizeToFit`.
        static let maxScaleFactor: CGFloat = 5

        static let backgroundColor: UIColor = .white
    }

    // MARK: - Overrides

    public override var document: PDFDocument? {
        get { super.document as? PDFDocumentFile }
        set {
            guard let newValue = newValue as? PDFDocumentFile else {
                updateLayout()
                return
            }

            super.document = newValue
            updateLayout()
        }
    }

    // MARK: - Initialization

    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = LocalConstants.backgroundColor
        enableDataDetectors = false
        translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }

    private func updateLayout() {
        autoScales = true
        minScaleFactor = scaleFactorForSizeToFit
        maxScaleFactor = scaleFactorForSizeToFit * LocalConstants.maxScaleFactor
    }

    // MARK: - Gesture Recognizers

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        clearSelection()
        return false
    }

    public override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer is UILongPressGestureRecognizer {
            gestureRecognizer.isEnabled = false
        }
        super.addGestureRecognizer(gestureRecognizer)
    }
}
