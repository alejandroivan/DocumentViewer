//
//  DocumentViewer.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 20-02-23.
//

import UIKit

open class DocumentViewer: UIViewController, DocumentViewerProtocol {

    // MARK: - Constants

    private enum LocalConstants {
        static let defaultTitle: String = "Document"
        static let backgroundColor: UIColor = .white

        enum ActivityIndicator {
            static let color: UIColor = .darkGray
            static let hidesWhenStopped: Bool = true
        }
    }

    // MARK: - Public Properties

    /// The document to be shown in the content view.
    public var document: Document? {
        didSet {
            if let document = document as? DocumentInternalDataSource {
                document.delegate = self
            }
            updateData()
        }
    }

    /// The state the current document is. It can be `nil` if the document isn't loaded.
    /// This is a convenience wrapper for `document?.state`.
    public var state: DocumentState? {
        document?.state
    }

    /// The URL to be used for sharing the document. It can be `nil` if the document isn't loaded.
    /// This is a convenience wrapper for `document?.shareURL`.
    public var shareURL: URL? {
        document?.shareURL
    }

    /// Determines if the `DocumentViewer` should show its own activity indicator while loading.
    public var shouldShowActivityIndicator: Bool = true {
        didSet {
            if !shouldShowActivityIndicator, activityIndicator.isAnimating {
                activityIndicator.stopAnimating()
            }
        }
    }

    /// The object which will be informed of state changes from the current `document`. If you
    /// are using a synchronous `DocumentSource` for it, you should set this `delegate` before
    /// the actual `document` property for delegate methods to work on state changes from it.
    open weak var delegate: DocumentViewerDelegate?

    /// The title to be used for both the navigation bar and also the document file name.
    /// When modified, it will update the `document.title` property accordingly.
    open override var title: String? {
        get { document?.title }
        set { document?.title = newValue ?? LocalConstants.defaultTitle }
    }

    /// A public view to be used as a header, if required.
    /// This view needs to have a `heightAnchor` with a constant set correctly to be shown.
    open var headerView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            updateLayout()
        }
    }

    /// A public view to be used as a footer, if required.
    /// This view needs to have a `heightAnchor` with a constant set correctly to be shown.
    open var footerView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            updateLayout()
        }
    }

    // MARK: - Private Properties

    private var contentViewTopConstraint: NSLayoutConstraint?
    private var contentViewBottomConstraint: NSLayoutConstraint?

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator: UIActivityIndicatorView

        if #available(iOS 13.0, *) {
            activityIndicator = .init(style: .large)
        } else {
            activityIndicator = .init(style: .whiteLarge)
        }

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = LocalConstants.ActivityIndicator.color
        activityIndicator.hidesWhenStopped = LocalConstants.ActivityIndicator.hidesWhenStopped

        return activityIndicator
    }()

    // MARK: - Initialization

    public required init(
        document: Document? = nil,
        delegate: DocumentViewerDelegate? = nil
    ) {
        super.init(nibName: nil, bundle: nil)

        if let document = document as? DocumentInternalDataSource {
            document.delegate = self
        }

        self.delegate = delegate
        self.document = document
    }

    @available(*, unavailable, message: "Use `init(document:delegate:)` instead.")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable, message: "Use `init(document:delegate:)` instead.")
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - View Controller Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LocalConstants.backgroundColor
        setUpViews()
        updateData()
    }

    // MARK: - Private Methods

    private func setUpViews() {
        setUpContentView()
        setUpActivityIndicator()
    }

    private func setUpContentView() {
        view.addSubview(contentView)

        NSLayoutConstraint.activate(
            [
                contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ].compactMap { $0 }
        )

        updateLayout()
    }

    private func setUpActivityIndicator() {
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: contentView.topAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    private func updateData() {
        if let document = document as? DocumentInternalDataSource {
            document.loadSource()
        }

        if isViewLoaded {
            contentView.subviews.forEach {
                $0.removeFromSuperview()
            }
        }

        guard let documentView = document?.documentView else {
            return
        }

        contentView.addSubview(documentView)

        NSLayoutConstraint.activate(
            [
                documentView.topAnchor.constraint(equalTo: contentView.topAnchor),
                documentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                documentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                documentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ]
        )
    }

    private func updateLayout() {
        if let topConstraint = contentViewTopConstraint {
            topConstraint.isActive = false
            contentView.removeConstraint(topConstraint)
        }

        if let bottomConstraint = contentViewBottomConstraint {
            bottomConstraint.isActive = false
            contentView.removeConstraint(bottomConstraint)
        }

        if let headerView = headerView {
            if headerView.superview == nil {
                view.addSubview(headerView)

                let heightConstraint = headerView.heightAnchor.constraint(lessThanOrEqualToConstant: 0)
                heightConstraint.priority = .defaultLow

                NSLayoutConstraint.activate([
                    headerView.topAnchor.constraint(equalTo: view.topAnchor),
                    headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    heightConstraint
                ])
            }
            contentViewTopConstraint = contentView.topAnchor.constraint(equalTo: headerView.bottomAnchor)
        } else {
            contentViewTopConstraint = contentView.topAnchor.constraint(equalTo: view.topAnchor)
        }

        if let footerView = footerView {
            if footerView.superview == nil {
                view.addSubview(footerView)

                let heightConstraint = footerView.heightAnchor.constraint(lessThanOrEqualToConstant: 0)
                heightConstraint.priority = .defaultLow

                NSLayoutConstraint.activate([
                    footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    heightConstraint
                ])
            }
            contentViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: footerView.topAnchor)
        } else {
            contentViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        }

        NSLayoutConstraint.activate(
            [
                contentViewTopConstraint,
                contentViewBottomConstraint
            ].compactMap { $0 }
        )
    }

    // MARK: - Public Methods

    open func showActivityIndicator() {
        guard shouldShowActivityIndicator else {
            return
        }
        activityIndicator.backgroundColor = contentView.backgroundColor
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
    }

    open func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }

    // MARK: - Overrides

    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) {
            self.delegate?.didFinishDismissingDocumentViewer?(self)
            completion?()
        }
    }
}

// MARK: - DocumentInternalDelegate

extension DocumentViewer: DocumentInternalDelegate {

    func didChangeStateForDocument(_ document: Document) {
        guard document === self.document else {
            return
        }

        switch document.state {
        case .loading:
            showActivityIndicator()
        default:
            hideActivityIndicator()
        }

        delegate?.didChangeStateForDocumentViewer?(self)
    }
}
