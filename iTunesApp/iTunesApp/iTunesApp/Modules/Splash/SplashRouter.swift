//
//  SplashRouter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import UIKit

enum SplashRoutes {
    case home
}

protocol SplashRouterProtocol {
    func navigate(_ route: SplashRoutes)
    func exitApplication()
}

final class SplashRouter {
    weak var viewController: SplashViewController?
}

extension SplashRouter: SplashRouterProtocol {
    func exitApplication() {
        exit(0)
    }
    
    static func createModule() -> SplashViewController {
        let view = SplashViewController()
        let interactor = SplashInteractor()
        let router = SplashRouter()
        let presenter = SplashPresenter(
            view: view,
            router: router,
            interactor: interactor
        )
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
    
    func navigate(_ route: SplashRoutes) {
        switch route {
        case .home:
            guard let window = viewController?.view.window else { return }
            
            let tabBarVC = MainRouter.createModule()
            
            let navigationController = UINavigationController(
                rootViewController: tabBarVC
            )
            window.rootViewController = navigationController
        }
    }
}
