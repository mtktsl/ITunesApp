//
//  MockSplashRouter.swift
//  iTunesAppTests
//
//  Created by Metin Tarık Kiki on 16.06.2023.
//

import Foundation
@testable import iTunesApp

final class MockSplashRouter: SplashRouterProtocol {
    
    weak var viewController: SplashViewControllerProtocol?
    
    static var createModuleInvoke = false
    static var createModuleCount = 0
    
    static func createModule() -> MockSplashViewController {
        let view = MockSplashViewController()
        let interactor = MockSplashInteractor()
        let router = MockSplashRouter()
        let presenter = MockSplashPresenter(
            view: view,
            interactor: interactor,
            router: router
        )
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        
        createModuleInvoke = true
        createModuleCount += 1
        
        return view
    }
    
    var navigateInvoke = false
    var navigateCount = 0
    var invokedNavigateParameters = [SplashRoutes]()
    
    func navigate(_ route: iTunesApp.SplashRoutes) {
        navigateInvoke = true
        navigateCount += 1
        invokedNavigateParameters.append(route)
    }
    
    var exitInvoke = false
    var exitCount = 0
    
    func exitApplication() {
        exitInvoke = true
        exitCount += 1
    }
}
