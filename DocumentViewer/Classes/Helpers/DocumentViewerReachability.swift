//
//  DocumentViewerReachability.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import SystemConfiguration

public protocol DocumentViewerReachabilityProtocol: AnyObject {

    /// Determines if the device is connected to the network.
    var isConnectedToNetwork: Bool { get }
}

public final class DocumentViewerReachability: DocumentViewerReachabilityProtocol {

    // MARK: - Public Properties

    public static let shared: DocumentViewerReachabilityProtocol = DocumentViewerReachability()

    // MARK: - Initialization

    public init() {}

    // MARK: - DocumentViewerReachabilityProtocol

    public var isConnectedToNetwork: Bool {
        var zeroAddress = sockaddr_in(
            sin_len: 0,
            sin_family: 0,
            sin_port: 0,
            sin_addr: in_addr(s_addr: 0),
            sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
        )
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        if
            let defaultRoute = defaultRouteReachability,
            SCNetworkReachabilityGetFlags(defaultRoute, &flags) == false
        {
            return false
        }

        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0

        return isReachable && !needsConnection
    }
}
