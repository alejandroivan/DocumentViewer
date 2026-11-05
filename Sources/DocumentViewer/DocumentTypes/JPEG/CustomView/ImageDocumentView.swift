//
//  ImageDocumentView.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import UIKit

final class ImageDocumentView: UIView {

    // MARK: - Constants

    private enum LocalConstants {
        static let backgroundColor: UIColor = .white

        enum ScrollView {
            static let bounces: Bool = true
            static let maximumZoomScale: CGFloat = 5
        }
    }

    // MARK: - Public Properties

    public var image: UIImage? {
        get { imageView.image }
        set {
            imageView.image = newValue
            updateLayout(force: true)
        }
    }

    // MARK: - Private Properties

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = LocalConstants.ScrollView.bounces
        scrollView.maximumZoomScale = LocalConstants.ScrollView.maximumZoomScale
        return scrollView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

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
        translatesAutoresizingMaskIntoConstraints = false
        setUpViews()
    }

    // MARK: - Private Methods

    private func setUpViews() {
        setUpScrollView()
        setUpImageView()
    }

    private func setUpScrollView() {
        addSubview(scrollView)
        scrollView.pinEdges(to: self)
        scrollView.delegate = self
    }

    private func setUpImageView() {
        scrollView.addSubview(imageView)
        imageView
            .pinEdges(to: scrollView.contentLayoutGuide)
            .pin(.width, to: scrollView.frameLayoutGuide)
            .pin(.height, to: scrollView.frameLayoutGuide)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }

    private func updateLayout(force: Bool = false) {
        guard let size = image?.size else {
            return
        }

        if force {
            setNeedsLayout()
            layoutIfNeeded()
        }

        let scrollViewSize = scrollView.bounds.size

        if
            size.width < scrollViewSize.width,
            size.height < scrollViewSize.height
        {
            imageView.contentMode = .center
        } else {
            imageView.contentMode = .scaleAspectFit
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ImageDocumentView: UIScrollViewDelegate {

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
