//
//  MainInteractor.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import NetworkStatusObserver

protocol MainInteractorProtocol: AnyObject {
    func checkInternetConnection()
    func getTabImageNames() -> [String]
}

protocol MainInteractorOutputProtocol: AnyObject {
    func onConnectionChanged(_ isConnected: Bool)
}

final class MainInteractor {
    var output: MainInteractorOutputProtocol!
    var networkStatusService: NetworkStatusObserverProtocol
    init(networkStatusService: NetworkStatusObserverProtocol = NetworkStatusObserver.shared) {
        self.networkStatusService = networkStatusService
        self.networkStatusService.delegates.append(.init(self))
    }
}

extension MainInteractor: MainInteractorProtocol {
    func getTabImageNames() -> [String] {
        return MainEntity.tabImageNames
    }
    
    func checkInternetConnection() {
        output.onConnectionChanged(NetworkStatusObserver.shared.isConnected)
    }
}

extension MainInteractor: NetworkStatusObserverDelegate {
    func onConnectionChanged(_ isConnected: Bool) {
        output.onConnectionChanged(isConnected)
    }
}
