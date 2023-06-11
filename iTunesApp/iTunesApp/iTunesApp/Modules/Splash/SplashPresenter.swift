//
//  SplashPresenter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation

extension SplashPresenter {
    fileprivate enum Constants {
        static let connectionErrorTitle = "Connection Error"
        static let connectionErrorMessage = "There is no internet connection."
        static let connectionErrorOkOption = "Retry"
    }
}

protocol SplashPresenterProtocol {
    func viewDidAppear()
}

final class SplashPresenter {
    unowned var view: SplashViewControllerProtocol!
    let router: SplashRouterProtocol!
    let interactor: SplashInteractorProtocol!
    
    init(
        view: SplashViewControllerProtocol!,
        router: SplashRouterProtocol!,
        interactor: SplashInteractorProtocol!
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
}

extension SplashPresenter: SplashPresenterProtocol {
    func viewDidAppear() {
        interactor.checkInternetConnection()
    }
}

extension SplashPresenter: SplashInteractorOutputProtocol {
    func onInternetResult(_ result: Bool) {
        if result {
            router.navigate(.home)
        } else {
            view.showError(
                title: Constants.connectionErrorTitle,
                message: Constants.connectionErrorMessage,
                okOption: Constants.connectionErrorOkOption,
                cancelOption: nil,
                onOk: { [weak self] (action: AnyObject) -> Void in
                    guard let self else { return }
                    self.interactor.checkInternetConnection()
                },
                onCancel: nil
            )
        }
    }
}
