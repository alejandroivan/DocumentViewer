//
//  DocumentViewer.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 20-02-23.
//

import UIKit

public class DocumentViewer: UIViewController {

    // MARK: - Constants

    private enum LocalConstants {
        static let defaultTitle: String = "Document"
        static let backgroundColor: UIColor = .white
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

    /// The object which will be informed of state changes from the current `document`. If you
    /// are using a synchronous `DocumentSource` for it, you should set this `delegate` before
    /// the actual `document` property for delegate methods to work on state changes from it.
    public weak var delegate: DocumentViewerDelegate?

    /// The title to be used for both the navigation bar and also the document file name.
    /// When modified, it will update the `document.title` property accordingly.
    public override var title: String? {
        get { document?.title }
        set { document?.title = newValue ?? LocalConstants.defaultTitle }
    }

    /// A public view to be used as a header, if required.
    /// This view needs to have a `heightAnchor` with a constant set correctly to be shown.
    public var headerView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            updateLayout()
        }
    }

    // MARK: - Private Properties

    private var contentViewTopConstraint: NSLayoutConstraint?

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .darkGray
        view.hidesWhenStopped = true
        view.style = .whiteLarge
        return view
    }()

    // MARK: - Initialization

    public init(
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

    public override func viewDidLoad() {
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
                contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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

        contentViewTopConstraint?.isActive = true
    }

    // MARK: - Public Methods

    public func showActivityIndicator() {
        activityIndicator.backgroundColor = contentView.backgroundColor
        activityIndicator.startAnimating()
    }

    public func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
}

// MARK: - AKDocumentDelegate

extension DocumentViewer: DocumentInternalDelegate {

    func didChangeStateForDocument(_ document: Document) {
        guard document === self.document else {
            return
        }

        switch document.state {
        case .loading:
            showActivityIndicator()
        default:
            hideLoadingIndicator()
        }

        delegate?.didChangeStateForDocumentViewer(self)
    }
}
