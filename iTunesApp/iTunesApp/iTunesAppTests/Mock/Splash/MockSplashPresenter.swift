//
//  MockSplashPresenter.swift
//  iTunesAppTests
//
//  Created by Metin Tarık Kiki on 16.06.2023.
//

import Foundation
@testable import iTunesApp

final class MockSplashPresenter: SplashPresenterProtocol {
    
    unowned var view: SplashViewControllerProtocol!
    var interactor: SplashInteractorProtocol!
    var router: SplashRouterProtocol!
    
    init(
        view: SplashViewControllerProtocol,
        interactor: SplashInteractorProtocol,
        router: SplashRouterProtocol
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    var didAppearInvoke = false
    var didAppearCount = 0
    
    func viewDidAppear() {
        didAppearInvoke = true
        didAppearCount += 1
        view.showError(title: "", message: "", okOption: nil, cancelOption: nil, onOk: nil, onCancel: nil)
        interactor.checkInternetConnection()
    }
    
    var internetResultInvoke = false
    var internetResultCount = 0
}


extension MockSplashPresenter: SplashInteractorOutputProtocol {
    
    func onInternetResult(_ result: Bool) {
        internetResultInvoke = true
        internetResultCount += 1
        router.navigate(.home)
    }
}
