//
//  ImageDocumentView.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 22-02-23.
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
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = LocalConstants.ScrollView.bounces
        scrollView.maximumZoomScale = LocalConstants.ScrollView.maximumZoomScale
        return scrollView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
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

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        scrollView.delegate = self
    }

    private func setUpImageView() {
        scrollView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),

            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
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
