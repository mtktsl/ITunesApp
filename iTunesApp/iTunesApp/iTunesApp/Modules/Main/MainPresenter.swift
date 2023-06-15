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
    func viewDidLoad()
    func detailRequest()
}

final class MainPresenter {
    unowned var view: MainViewControllerProtocol!
    let interactor: MainInteractorProtocol!
    let router: MainRouterProtocol!
    
    private var isPopupOpen = false
    
    init(
        view: MainViewControllerProtocol!,
        interactor: MainInteractorProtocol!,
        router: MainRouterProtocol!
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension MainPresenter: MainPresenterProtocol {
    func detailRequest() {
        router.navigate(.detailPage)
    }
    
    func viewDidLoad() {
        let imageNames = interactor.getTabImageNames()
        view.setupTabBar(imageNames: imageNames)
    }
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
