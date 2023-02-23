//
//  ViewController.swift
//  DocumentViewer_Example
//
//  Created by Alejandro Melo Domínguez on 02/21/2023.
//  Copyright (c) 2023 Alejandro Melo Domínguez. All rights reserved.
//

import DocumentViewer
import UIKit

class ViewController: UIViewController {

    // MARK: - Constants

    private enum LocalConstants {
        enum StackView {
            static let insets: UIEdgeInsets = .init(top: 20, left: 20, bottom: 0, right: 20)
        }
    }

    private lazy var demos: [UIView] = [

        // PDF

        getTitleView(title: "PDF"),

        getButton(
            title: "Modal (remote URL)",
            selector: #selector(didTapPDFModalButtonRemote(_:))
        ),
        getButton(
            title: "Modal (local URL)",
            selector: #selector(didTapPDFModalButton(_:))
        ),
        getButton(
            title: "Modal (local URL - footer view)",
            selector: #selector(didTapPDFModalButtonFooterView(_:))
        ),
        getButton(
            title: "Modal (local URL - password protected)",
            selector: #selector(didTapPDFModalButtonPasswordProtected(_:))
        ),
        getButton(
            title: "Modal (local URL - wrong password)",
            selector: #selector(didTapPDFModalButtonPasswordProtectedWrongPassword(_:))
        ),
        getButton(
            title: "Push (remote URL)",
            selector: #selector(didTapPDFPushButtonRemote(_:))
        ),
        getButton(
            title: "Push (local URL)",
            selector: #selector(didTapPDFPushButton(_:))
        ),
        getButton(
            title: "Push (local URL - password protected)",
            selector: #selector(didTapPDFPushButtonPasswordProtected(_:))
        ),
        getButton(
            title: "Push (local URL - wrong password)",
            selector: #selector(didTapPDFPushButtonPasswordProtectedWrongPassword(_:))
        ),

        // Images

        getTitleView(title: "Images"),

        getButton(
            title: "Modal (remote URL)",
            selector: #selector(didTapImageModalButtonRemote(_:))
        ),
        getButton(
            title: "Modal (local URL)",
            selector: #selector(didTapImageModalButton(_:))
        ),
        getButton(
            title: "Modal (remote URL - transparency)",
            selector: #selector(didTapImageModalButtonTransparencyRemote(_:))
        ),
        getButton(
            title: "Modal (local URL - transparency)",
            selector: #selector(didTapImageModalButtonTransparency(_:))
        )
    ]

    // MARK: - Private Properties

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        return scrollView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()

    private weak var documentViewer: DocumentViewer?

    private var isDocumentViewerModal = false

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "DocumentViewer Example"
        view.backgroundColor = .white
        setUpViews()
    }

    // MARK: - View Hierarchy

    private func setUpViews() {
        setUpScrollView()
        setUpStackView()
        setUpDemoViews()
    }

    private func setUpScrollView() {
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    private func setUpStackView() {
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo: scrollView.topAnchor,
                constant: LocalConstants.StackView.insets.top
            ),
            stackView.bottomAnchor.constraint(
                lessThanOrEqualTo: scrollView.bottomAnchor,
                constant: -LocalConstants.StackView.insets.bottom
            ),
            stackView.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor,
                constant: LocalConstants.StackView.insets.left
            ),
            stackView.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor,
                constant: -LocalConstants.StackView.insets.right
            ),
            stackView.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor,
                constant: -(LocalConstants.StackView.insets.left + LocalConstants.StackView.insets.right)
            ),
        ])
    }

    private func setUpDemoViews() {
        demos.forEach {
            stackView.addArrangedSubview($0)
        }
    }

    // MARK: - Helpers

    private func getTitleView(title: String) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray.withAlphaComponent(0.2)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.font = .boldSystemFont(ofSize: 10)
        label.textAlignment = .left
        label.text = title

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4)
        ])

        return view
    }

    private func getButton(title: String, selector: Selector) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }

    private func displayError(title: String, message: String, on viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertController.addAction(.init(title: "Close", style: .default, handler: { _ in
            if self.isDocumentViewerModal {
                viewController.dismiss(animated: true)
            } else {
                viewController.navigationController?.popViewController(animated: true)
            }
        }))

        DispatchQueue.main.async {
            viewController.present(alertController, animated: true)
        }
    }

    // MARK: - Button Targets

    // MARK: PDF

    @objc
    private func didTapPDFModalButtonRemote(_ button: UIButton) {
        let document = PDFDocumentImplementation(
            title: "Remote PDF",
            source: .url(Demos.pdfURL)
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        let headerView = HeaderView()
        headerView.delegate = self

        documentViewer.headerView = headerView

        self.documentViewer = documentViewer
        isDocumentViewerModal = true
        navigationController?.present(documentViewer, animated: true)
    }

    @objc
    private func didTapPDFModalButton(_ button: UIButton) {
        let documentViewer = DocumentViewer()
        documentViewer.document = PDFDocumentImplementation(
            title: "Local PDF",
            source: .base64(Demos.pdfBase64)
        )

        let headerView = HeaderView()
        headerView.delegate = self

        documentViewer.headerView = headerView

        self.documentViewer = documentViewer
        isDocumentViewerModal = true
        navigationController?.present(documentViewer, animated: true)
    }

    @objc
    private func didTapPDFModalButtonFooterView(_ button: UIButton) {
        let documentViewer = DocumentViewer()
        documentViewer.document = PDFDocumentImplementation(
            title: "Local PDF",
            source: .base64(Demos.pdfBase64)
        )

        let headerView = HeaderView()
        headerView.delegate = self

        let footerView = UIView()
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = .green
        let footerHeightConstraint = footerView.heightAnchor.constraint(equalToConstant: 40)
        footerHeightConstraint.isActive = true

        documentViewer.headerView = headerView
        documentViewer.footerView = footerView

        self.documentViewer = documentViewer
        isDocumentViewerModal = true
        navigationController?.present(documentViewer, animated: true)
    }

    @objc
    private func didTapPDFModalButtonPasswordProtected(_ button: UIButton) {
        let document = PDFDocumentImplementation(
            title: "Local PDF (password)",
            source: .base64(Demos.base64PasswordProtected),
            password: "12345"
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        let headerView = HeaderView()
        headerView.delegate = self

        documentViewer.headerView = headerView

        self.documentViewer = documentViewer
        isDocumentViewerModal = true
        navigationController?.present(documentViewer, animated: true)
    }

    @objc
    private func didTapPDFModalButtonPasswordProtectedWrongPassword(_ button: UIButton) {
        let document = PDFDocumentImplementation(
            title: "Local PDF (password)",
            source: .base64(Demos.base64PasswordProtected),
            password: "a wrong password" // correct password: "12345"
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        let headerView = HeaderView()
        headerView.delegate = self

        documentViewer.headerView = headerView

        self.documentViewer = documentViewer
        isDocumentViewerModal = true
        navigationController?.present(documentViewer, animated: true)
    }

    @objc
    private func didTapPDFPushButtonRemote(_ button: UIButton) {
        let document = PDFDocumentImplementation(
            title: "Remote PDF",
            source: .url(Demos.pdfURL)
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        self.documentViewer = documentViewer

        isDocumentViewerModal = false
        navigationController?.pushViewController(documentViewer, animated: true)
    }

    @objc
    private func didTapPDFPushButton(_ button: UIButton) {
        let document = PDFDocumentImplementation(
            title: "Local PDF",
            source: .base64(Demos.pdfBase64)
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        self.documentViewer = documentViewer

        isDocumentViewerModal = false
        navigationController?.pushViewController(documentViewer, animated: true)
    }

    @objc
    private func didTapPDFPushButtonPasswordProtected(_ button: UIButton) {
        let document = PDFDocumentImplementation(
            title: "Local PDF (password)",
            source: .base64(Demos.base64PasswordProtected),
            password: "12345"
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        self.documentViewer = documentViewer

        isDocumentViewerModal = false
        navigationController?.pushViewController(documentViewer, animated: true)
    }

    @objc
    private func didTapPDFPushButtonPasswordProtectedWrongPassword(_ button: UIButton) {
        let document = PDFDocumentImplementation(
            title: "Local PDF (password)",
            source: .base64(Demos.base64PasswordProtected),
            password: "a wrong password"
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        self.documentViewer = documentViewer

        isDocumentViewerModal = false
        navigationController?.pushViewController(documentViewer, animated: true)
    }

    // MARK: Image

    @objc
    private func didTapImageModalButtonRemote(_ button: UIButton) {
        let document = ImageDocumentImplementation(
            title: "Remote image",
            source: .url(Demos.jpegURL)
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        let headerView = HeaderView()
        headerView.delegate = self

        documentViewer.headerView = headerView

        self.documentViewer = documentViewer
        isDocumentViewerModal = true
        navigationController?.present(documentViewer, animated: true)
    }

    @objc
    private func didTapImageModalButton(_ button: UIButton) {
        let document = ImageDocumentImplementation(
            title: "Local image",
            source: .base64(Demos.jpegBase64)
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        let headerView = HeaderView()
        headerView.delegate = self

        documentViewer.headerView = headerView

        self.documentViewer = documentViewer
        isDocumentViewerModal = true
        navigationController?.present(documentViewer, animated: true)
    }

    @objc
    private func didTapImageModalButtonTransparencyRemote(_ button: UIButton) {
        let document = ImageDocumentImplementation(
            title: "Local image (transparency)",
            source: .url(Demos.pngURL)
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        let headerView = HeaderView()
        headerView.delegate = self

        documentViewer.headerView = headerView

        self.documentViewer = documentViewer
        isDocumentViewerModal = true
        navigationController?.present(documentViewer, animated: true)
    }

    @objc
    private func didTapImageModalButtonTransparency(_ button: UIButton) {
        let document = ImageDocumentImplementation(
            title: "Local image (transparency)",
            source: .base64(Demos.pngBase64)
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        let headerView = HeaderView()
        headerView.delegate = self

        documentViewer.headerView = headerView

        self.documentViewer = documentViewer
        isDocumentViewerModal = true
        navigationController?.present(documentViewer, animated: true)
    }
}

// MARK: - DocumentViewerDelegate

extension ViewController: DocumentViewerDelegate {

    func didChangeStateForDocumentViewer(_ documentViewer: DocumentViewer) {
        switch documentViewer.state {
        case .passwordProtected:
            displayError(
                title: "Invalid password",
                message: "The entered password for the document is invalid.",
                on: documentViewer
            )
        default:
            print("STATE: \(String(describing: documentViewer.state))")
            break
        }
    }
}

// MARK: - HeaderViewDelegate

extension ViewController: HeaderViewDelegate {

    func didTapCloseButtonOnHeaderView(_ headerView: HeaderView) {
        documentViewer?.dismiss(animated: true)
    }

    func didTapShareButtonOnHeaderView(_ headerView: HeaderView) {
        headerView.isShareButtonEnabled = false

        guard let shareURL = documentViewer?.shareURL else {
            headerView.isShareButtonEnabled = true
            return
        }

        let shareController = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)

        self.documentViewer?.present(shareController, animated: true) {
            headerView.isShareButtonEnabled = true
        }
    }
}
