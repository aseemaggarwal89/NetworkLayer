//
//  NetworkConnectivity.swift
//  ConnectUp
//
//  Created by Aseem Aggarwal on 02/05/22.
//

import Foundation
import Alamofire
import Combine

enum NetworkStatus {
    case reachable
    case notreachable
}

class NetworkConnectivity {
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    private let networkConnectionStateSubject = CurrentValueSubject<NetworkStatus, Never>(.notreachable)
    private var disposeBag = Set<AnyCancellable>()
    private var networkState: NetworkStatus = .notreachable
    
    var isNetworkReachable: AnyPublisher<NetworkStatus, Never> {
        return networkConnectionStateSubject.flatMap({ [weak self] status -> AnyPublisher<NetworkStatus, Never> in
            if self?.networkState != status {
                self?.networkState = status
                return Just(status).eraseToAnyPublisher()
            } else {
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }
        }).eraseToAnyPublisher()
    }

    func startNetworkReachabilityObserver() {
        // start listening
        reachabilityManager?.startListening(onUpdatePerforming: {[weak self] status in
            switch status {
            case .notReachable, .unknown:
                self?.networkConnectionStateSubject.send(NetworkStatus.notreachable)
            case .reachable:
                self?.networkConnectionStateSubject.send(NetworkStatus.reachable)
            }
        })
    }
    
    func stopListening() {
        reachabilityManager?.stopListening()
    }
}
