//
//  DocumentViewer.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
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

        enum HeaderView {
            static let useSafeArea: Bool = false
        }

        enum FooterView {
            static let useSafeArea: Bool = false
        }
    }

    // MARK: - Public Properties

    /// The document to be shown in the content view.
    public var document: Document? {
        didSet {
            if let document = document as? DocumentInternalDataSource {
                document.delegate = self
            }
            if isViewLoaded {
                updateData()
            }
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
                hideActivityIndicator()
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

    /// Determines if the header view top margin should consider the safe area or not.
    /// If this value is `false`, it will be pinned to the top of the view controller,
    /// which usually means it goes below the status bar.
    open var headerViewUsesSafeArea: Bool = LocalConstants.HeaderView.useSafeArea {
        didSet {
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

    /// Determines if the footer view bottom margin should consider the safe area or not.
    /// If this value is `false`, it will be pinned to the bottom of the view controller,
    /// which usually means it goes below the safe area bottom space, making this view
    /// pass below the "home indicator" on devices without a physical home button.
    open var footerViewUsesSafeArea: Bool = LocalConstants.FooterView.useSafeArea {
        didSet {
            updateLayout()
        }
    }

    // MARK: - Private Properties

    // MARK: Views

    private let headerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let footerContainerView: UIView = {
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

        activityIndicator.color = LocalConstants.ActivityIndicator.color
        activityIndicator.hidesWhenStopped = LocalConstants.ActivityIndicator.hidesWhenStopped

        return activityIndicator
    }()

    // MARK: Constraints

    private var headerContainerSafeAreaTopConstraint: NSLayoutConstraint?
    private var headerContainerSuperviewTopConstraint: NSLayoutConstraint?
    private var headerContainerHeightConstraint: NSLayoutConstraint?

    private var footerContainerSafeAreaBottomConstraint: NSLayoutConstraint?
    private var footerContainerSuperviewBottomConstraint: NSLayoutConstraint?
    private var footerContainerHeightConstraint: NSLayoutConstraint?

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
        presentationController?.delegate = self
        setUpViews()
        updateData()
        updateLayout()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            delegate?.documentViewer?(self, didFinishPresenting: .navigationStack)
        }
    }

    // MARK: - Private Methods

    private func setUpViews() {
        setUpHeaderContainerView()
        setUpFooterContainerView()
        setUpContentView()
        setUpActivityIndicator()

        view.bringSubviewToFront(headerContainerView)
        view.bringSubviewToFront(footerContainerView)
    }

    private func setUpHeaderContainerView() {
        view.addSubview(headerContainerView)

        headerContainerHeightConstraint = headerContainerView.pinConstraint(
            .height,
            constant: 0,
            isActive: headerView == nil
        )

        headerContainerSafeAreaTopConstraint = headerContainerView.pinConstraint(
            .top,
            to: view.safeAreaLayoutGuide.topAnchor,
            isActive: headerViewUsesSafeArea
        )

        headerContainerSuperviewTopConstraint = headerContainerView.pinConstraint(
            .top,
            to: view.topAnchor,
            isActive: !headerViewUsesSafeArea
        )

        headerContainerView.pin(.leading, .trailing, to: view)
    }

    private func setUpFooterContainerView() {
        view.addSubview(footerContainerView)

        footerContainerHeightConstraint = footerContainerView.pinConstraint(
            .height,
            constant: 0,
            isActive: footerView == nil
        )

        footerContainerSafeAreaBottomConstraint = footerContainerView.pinConstraint(
            .bottom,
            to: view.safeAreaLayoutGuide.bottomAnchor,
            isActive: footerViewUsesSafeArea
        )

        footerContainerSuperviewBottomConstraint = footerContainerView.pinConstraint(
            .bottom,
            to: view.bottomAnchor,
            isActive: !footerViewUsesSafeArea
        )

        footerContainerView.pin(.leading, .trailing, to: view)
    }

    private func setUpContentView() {
        view.addSubview(contentView)

        contentView
            .pin(.top, to: headerContainerView.bottomAnchor)
            .pin(.bottom, to: footerContainerView.topAnchor)
            .pin(.leading, .trailing, to: view)
    }

    private func setUpActivityIndicator() {
        view.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.pinCenter(to: contentView)
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

        if documentView.superview != contentView {
            contentView.addSubview(documentView)
            documentView.pinEdges(to: contentView)
            view.setNeedsLayout()
        }
    }

    private func updateLayout() {
        updateSafeAreaLayout()
        updateHeaderViewLayout()
        updateFooterViewLayout()
        view.setNeedsLayout()
    }

    private func updateSafeAreaLayout() {
        let isHeaderSafeAreaEnabled = headerViewUsesSafeArea && headerView != nil
        headerContainerSafeAreaTopConstraint?.isActive = isHeaderSafeAreaEnabled
        headerContainerSuperviewTopConstraint?.isActive = !isHeaderSafeAreaEnabled

        let isFooterSafeAreaEnabled = footerViewUsesSafeArea && footerView != nil
        footerContainerSafeAreaBottomConstraint?.isActive = isFooterSafeAreaEnabled
        footerContainerSuperviewBottomConstraint?.isActive = !isFooterSafeAreaEnabled
    }

    private func updateHeaderViewLayout() {
        guard let headerView = headerView else {
            headerContainerHeightConstraint?.isActive = true
            return
        }

        headerContainerHeightConstraint?.isActive = false
        headerContainerView.addSubview(headerView)

        headerView.pinEdges(to: headerContainerView)
    }

    private func updateFooterViewLayout() {
        guard let footerView = footerView else {
            footerContainerHeightConstraint?.isActive = true
            return
        }

        footerContainerHeightConstraint?.isActive = false
        footerContainerView.addSubview(footerView)

        footerView.pinEdges(to: footerContainerView)
    }

    // MARK: - Public Methods

    open func showActivityIndicator() {
        guard shouldShowActivityIndicator else {
            return
        }

        contentView.isHidden = true

        view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
    }

    open func hideActivityIndicator() {
        contentView.isHidden = false
        activityIndicator.stopAnimating()
    }

    // MARK: - Overrides

    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) {
            self.delegate?.documentViewer?(self, didFinishPresenting: .modal)
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

// MARK: - UIViewControllerTransitioningDelegate

extension DocumentViewer: UIAdaptivePresentationControllerDelegate {

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard presentationController.presentedViewController == self else {
            return
        }
        delegate?.documentViewer?(self, didFinishPresenting: .modal)
    }
}
