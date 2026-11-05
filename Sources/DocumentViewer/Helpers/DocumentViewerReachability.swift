//
//  DocumentViewerReachability.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//  Last updated: 2026-11-05
//
//  Provided under the MIT license.
//

import Network

public protocol DocumentViewerReachabilityProtocol: Sendable {

    /// Determines if the device is connected to the network.
    var isConnectedToNetwork: Bool { get }

    /// Determines if the connection is expensive (e.g mobile data, etc.)
    var isExpensiveConnection: Bool { get }
}

public final class DocumentViewerReachability: DocumentViewerReachabilityProtocol, @unchecked Sendable {

    // MARK: - Public Properties

    public static let shared: any DocumentViewerReachabilityProtocol = DocumentViewerReachability()

    public var isConnectedToNetwork: Bool {
        get { queue.sync { _isConnected }}
        set { queue.sync(flags: .barrier) { _isConnected = newValue } }
    }

    public var isExpensiveConnection: Bool {
        get { queue.sync { _isExpensive }}
        set { queue.sync(flags: .barrier) { _isExpensive = newValue } }
    }

    // MARK: - Private Properties

    private var task: Task<Void, Never>?
    private let queue = DispatchQueue(label: "DocumentViewerReachability.sendable")

    private var _isConnected = false
    private var _isExpensive = false

    private let monitor = NWPathMonitor()


    // MARK: - Initialization

    init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Private Properties

    private func startMonitoring() {
        stopMonitoring()

        task = Task { [weak self, monitor] in
            guard !Task.isCancelled else {
                return
            }

            for await path in monitor {
                guard !Task.isCancelled else {
                    return
                }

                self?.isConnectedToNetwork = path.status == .satisfied
                self?.isExpensiveConnection = path.isExpensive
            }
        }
    }

    private func stopMonitoring() {
        task?.cancel()
    }
}
