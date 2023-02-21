//
//  ViewController.swift
//  DocumentViewer
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

    private lazy var demos: [UIButton] = [
        getButton(
            title: "Modal (remote URL)",
            selector: #selector(didTapModalButtonRemote(_:))
        ),
        getButton(
            title: "Modal (local URL)",
            selector: #selector(didTapModalButton(_:))
        ),
        getButton(
            title: "Modal (local URL - password protected)",
            selector: #selector(didTapModalButtonPasswordProtected(_:))
        ),
        getButton(
            title: "Modal (local URL - wrong password)",
            selector: #selector(didTapModalButtonPasswordProtectedWrongPassword(_:))
        ),
        getButton(
            title: "Push",
            selector: #selector(didTapPushButton(_:))
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
        stackView.alignment = .leading
        return stackView
    }()

    private weak var documentViewer: DocumentViewer?

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
        setUpDemoButtons()
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

    private func setUpDemoButtons() {
        demos.forEach {
            stackView.addArrangedSubview($0)
        }
    }

    // MARK: - Helpers

    private func getButton(title: String, selector: Selector) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textAlignment = .left
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }

    private func displayError(title: String, message: String, on viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertController.addAction(.init(title: "Close", style: .default, handler: { _ in
            viewController.dismiss(animated: true)
        }))

        DispatchQueue.main.async {
            viewController.present(alertController, animated: true)
        }
    }

    // MARK: - Button Targets

    @objc
    private func didTapModalButtonRemote(_ button: UIButton) {
        let document = PDFDocumentImplementation(
            title: "Remote document",
            source: .url(Self.demoURL)
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        let headerView = HeaderView()
        headerView.delegate = self

        documentViewer.headerView = headerView

        self.documentViewer = documentViewer
        navigationController?.present(documentViewer, animated: true)
    }

    @objc
    private func didTapModalButton(_ button: UIButton) {
        let documentViewer = DocumentViewer()
        documentViewer.document = PDFDocumentImplementation(
            title: "Local document",
            source: .base64(Self.base64)
        )

        let headerView = HeaderView()
        headerView.delegate = self

        documentViewer.headerView = headerView

        self.documentViewer = documentViewer
        navigationController?.present(documentViewer, animated: true)
    }

    @objc
    private func didTapModalButtonPasswordProtected(_ button: UIButton) {
        let document = PDFDocumentImplementation(
            title: "Local document (password)",
            source: .base64(Self.base64PasswordProtected),
            password: "12345"
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        let headerView = HeaderView()
        headerView.delegate = self

        documentViewer.headerView = headerView

        self.documentViewer = documentViewer
        navigationController?.present(documentViewer, animated: true)
    }

    @objc
    private func didTapModalButtonPasswordProtectedWrongPassword(_ button: UIButton) {
        let document = PDFDocumentImplementation(
            title: "Local document (password)",
            source: .base64(Self.base64PasswordProtected),
            password: "a wrong password" // correct password: "12345"
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        let headerView = HeaderView()
        headerView.delegate = self

        documentViewer.headerView = headerView

        self.documentViewer = documentViewer
        navigationController?.present(documentViewer, animated: true)
    }

    @objc
    private func didTapPushButton(_ button: UIButton) {
        let document = PDFDocumentImplementation(
            title: "Base64 document",
            source: .base64(Self.base64)
        )
        let documentViewer = DocumentViewer(document: document, delegate: self)

        self.documentViewer = documentViewer
        navigationController?.pushViewController(documentViewer, animated: true)
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

// MARK: - Example Data

extension ViewController {

    static let demoURL = URL(string: "https://www.osce.org/files/f/documents/a/4/86597.pdf")

    static let base64 = "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Pj4KZW5kb2JqCjEwIDAgb2JqCjw8IC9Qcm9kdWNlciAobWFjT1MgVmVyc2lvbiAxMi42LjMgXChCdWlsZCAyMUc0MTlcKSBRdWFydHogUERGQ29udGV4dCkgL0NyZWF0aW9uRGF0ZQooRDoyMDIzMDIyMTIxMDQxM1owMCcwMCcpIC9Nb2REYXRlIChEOjIwMjMwMjIxMjEwNDEzWjAwJzAwJykgPj4KZW5kb2JqCnhyZWYKMCAxMQowMDAwMDAwMDAwIDY1NTM1IGYgCjAwMDAwMDAxNDcgMDAwMDAgbiAKMDAwMDAwNzk2NCAwMDAwMCBuIAowMDAwMDAwMDIyIDAwMDAwIG4gCjAwMDAwMDAyMjcgMDAwMDAgbiAKMDAwMDAwMDMxNiAwMDAwMCBuIAowMDAwMDA3OTI5IDAwMDAwIG4gCjAwMDAwMDQ4MDQgMDAwMDAgbiAKMDAwMDAwNTIxNyAwMDAwMCBuIAowMDAwMDA4MDQ3IDAwMDAwIG4gCjAwMDAwMDgxMTAgMDAwMDAgbiAKdHJhaWxlcgo8PCAvU2l6ZSAxMSAvUm9vdCA5IDAgUiAvSW5mbyAxMCAwIFIgL0lEIFsgPGZkYmM0NjYyMWZlYTZlNWM2NmRiNmYyYmIzMmJkM2E4Pgo8ZmRiYzQ2NjIxZmVhNmU1YzY2ZGI2ZjJiYjMyYmQzYTg+IF0gPj4Kc3RhcnR4cmVmCjgyNzUKJSVFT0YK"

    static let base64PasswordProtected = "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cjlF5iQYCmVuZHN0cmVhbQplbmRvYmoKNiAwIG9iagpbIC9JQ0NCYXNlZCA4IDAgUiBdCmVuZG9iagoyIDAgb2JqCjw8IC9UeXBlIC9QYWdlcyAvTWVkaWFCb3ggWzAgMCA2MTIgNzkyXSAvQ291bnQgMSAvS2lkcyBbIDEgMCBSIF0gPj4KZW5kb2JqCjkgMCBvYmoKPDwgL1R5cGUgL0NhdGFsb2cgL1BhZ2VzIDIgMCBSIC9WZXJzaW9uIC8xLjYgPj4KZW5kb2JqCjEwIDAgb2JqCjw8IC9Qcm9kdWNlciAoQlwwMTTFr95sW+NkZ9xLRfa/a0RYudfNRFwwMTRTWN5cMDA1jeRcMDE2IePcrNxCW41GTUpzU5Hna5VcMDE0MV6Mdurl+M2lclwwMze13M7GXCniq9iE8HO2elwwMTFcMDE03cKJX/KAoCKCwo5cMDM1mjxcMDAxPdpQXDAzM/yMhHM44ZMkINM9soVcMDAw52fK0W2t7IfZx1wwMzH64PTOSIXZK7iTKQovQ3JlYXRpb25EYXRlIChCXDAxNMWv3mxb42Rn3EtF9r9rZNV9MG6Y4p83e3Sbq8ifKonBMHBo5D9mrV6mXDAxNZTzKtwpIC9Nb2REYXRlCihCXDAxNMWv3mxb42Rn3EtF9r9rZNV9MG6Y4p83e3Sbq8ifKonBMHBo5D9mrV6mXDAxNZTzKtwpID4+CmVuZG9iagoxMSAwIG9iago8PCAvRmlsdGVyIC9TdGFuZGFyZCAvViA0IC9SIDQgL0xlbmd0aCAxMjggL0NGIDw8IC9TdGRDRiA8PCAvQXV0aEV2ZW50IC9Eb2NPcGVuCi9DRk0gL0FFU1YyIC9MZW5ndGggMTYgPj4gPj4gL1N0bUYgL1N0ZENGIC9TdHJGIC9TdGRDRiAvTyA8MTczNzY0NjI5ZTkwNjZiZWIyNmYwZGViYzdkMGE3MWU0MGQzODYyNDNiYzI4NDM1Y2M5ODM1ZjdiZjU1Mjk0Mz4KL1UgPGY0NDVhMzg3NWNjYmNlNTUzYzZiOGVlMzk4OTBkNTM4MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDA+IC9QIC0zMzkyCj4+CmVuZG9iagp4cmVmCjAgMTIKMDAwMDAwMDAwMCA2NTUzNSBmIAowMDAwMDAwMTg5IDAwMDAwIG4gCjAwMDAwMDgxNTkgMDAwMDAgbiAKMDAwMDAwMDAyMiAwMDAwMCBuIAowMDAwMDAwMzAzIDAwMDAwIG4gCjAwMDAwMDAzOTIgMDAwMDAgbiAKMDAwMDAwODEyNCAwMDAwMCBuIAowMDAwMDA0OTI0IDAwMDAwIG4gCjAwMDAwMDUzODQgMDAwMDAgbiAKMDAwMDAwODI0MiAwMDAwMCBuIAowMDAwMDA4MzA1IDAwMDAwIG4gCjAwMDAwMDg2NDUgMDAwMDAgbiAKdHJhaWxlcgo8PCAvU2l6ZSAxMiAvUm9vdCA5IDAgUiAvRW5jcnlwdCAxMSAwIFIgL0luZm8gMTAgMCBSIC9JRCBbIDwzNGUzNDEzNjNlODY2YTc5MDAzODkyMDk3YTAwZTc1MD4KPDM0ZTM0MTM2M2U4NjZhNzkwMDM4OTIwOTdhMDBlNzUwPiBdID4+CnN0YXJ0eHJlZgo4OTQ4CiUlRU9GCg=="
}
