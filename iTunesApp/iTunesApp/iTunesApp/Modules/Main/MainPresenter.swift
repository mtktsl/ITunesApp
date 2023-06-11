//
//  MainPresenter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation

extension MainPresenter {
    fileprivate enum Constants {
        static let connectionErrorTitle = "Connection Error"
        static let connectionErrorMessage = "There is no internet connection."
        static let connectionErrorOkOption = "Retry"
    }
}

protocol MainPresenterProtocol: AnyObject {
    
}

final class MainPresenter {
    unowned var view: MainViewControllerProtocol!
    let interactor: MainInteractorProtocol!
    
    private var isPopupOpen = false
    
    init(
        view: MainViewControllerProtocol!,
        interactor: MainInteractorProtocol!
    ) {
        self.view = view
        self.interactor = interactor
    }
}

extension MainPresenter: MainPresenterProtocol {

}

extension MainPresenter: MainInteractorOutputProtocol {
    func onConnectionChanged(_ isConnected: Bool) {
        if isPopupOpen || isConnected { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            isPopupOpen = true
            view.showError(
                title: Constants.connectionErrorTitle,
                message: Constants.connectionErrorMessage,
                okOption: Constants.connectionErrorOkOption,
                cancelOption: nil,
                
                onOk: { [weak self] (_:AnyObject) -> Void in
                    guard let self else { return }
                    isPopupOpen = false
                    interactor.checkInternetConnection()
                },
                
                onCancel: nil)
        }
    }
}
