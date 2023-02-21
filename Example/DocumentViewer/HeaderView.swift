//
//  HeaderView.swift
//  DocumentViewer_Example
//
//  Created by Alejandro Melo Domínguez on 21-02-23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

@objc
protocol HeaderViewDelegate: AnyObject {

    @objc
    optional func didTapCloseButtonOnHeaderView(_ headerView: HeaderView)

    @objc
    optional func didTapShareButtonOnHeaderView(_ headerView: HeaderView)
}

class HeaderView: UIView {

    // MARK: - Constants

    private enum LocalConstants {
        static let maximumHeight: CGFloat = 60
        static let backgroundColor: UIColor = .lightGray

        enum Buttons {
            enum Color {
                static let enabled: UIColor = .systemBlue
                static let disabled: UIColor = .darkGray
            }
        }

        enum Close {
            static let title: String = "Close"
            static let insets: UIEdgeInsets = .init(top: 8, left: 0, bottom: 8, right: 20)
        }

        enum Share {
            static let title: String = "Share"
            static let insets: UIEdgeInsets = .init(top: 8, left: 0, bottom: 8, right: 20)
        }
    }

    // MARK: - Public Properties

    public weak var delegate: HeaderViewDelegate?

    public var isShareButtonEnabled: Bool {
        get { shareButton.isEnabled }
        set { shareButton.isEnabled = newValue }
    }

    public var isCloseButtonEnabled: Bool {
        get { closeButton.isEnabled }
        set { closeButton.isEnabled = newValue }
    }

    // MARK: - Private Properties

    private let closeButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(LocalConstants.Buttons.Color.enabled, for: .normal)
        button.setTitleColor(LocalConstants.Buttons.Color.disabled, for: .disabled)
        button.setTitle(LocalConstants.Close.title, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let shareButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(LocalConstants.Buttons.Color.enabled, for: .normal)
        button.setTitleColor(LocalConstants.Buttons.Color.disabled, for: .disabled)
        button.setTitle(LocalConstants.Share.title, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialization

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = LocalConstants.backgroundColor
        setUpViews()
    }

    // MARK: - View Hierarchy

    private func setUpViews() {
        setUpCloseButton()
        setUpShareButton()
    }

    private func setUpCloseButton() {
        addSubview(closeButton)

        closeButton.addTarget(self, action: #selector(didTapCloseButton(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: LocalConstants.Close.insets.top
            ),
            closeButton.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -LocalConstants.Close.insets.bottom
            ),
            closeButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -LocalConstants.Close.insets.right
            ),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setUpShareButton() {
        addSubview(shareButton)

        shareButton.addTarget(self, action: #selector(didTapShareButton(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            shareButton.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: LocalConstants.Close.insets.top
            ),
            shareButton.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -LocalConstants.Close.insets.bottom
            ),
            shareButton.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor,
                constant: LocalConstants.Share.insets.left
            ),
            shareButton.trailingAnchor.constraint(
                equalTo: closeButton.leadingAnchor,
                constant: -LocalConstants.Close.insets.right
            ),
            shareButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Button Targets

    @objc
    private func didTapCloseButton(_ button: UIButton) {
        delegate?.didTapCloseButtonOnHeaderView?(self)
    }

    @objc
    private func didTapShareButton(_ button: UIButton) {
        delegate?.didTapShareButtonOnHeaderView?(self)
    }
}
