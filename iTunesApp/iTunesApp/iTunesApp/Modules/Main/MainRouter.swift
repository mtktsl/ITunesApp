//
//  MainModuleCreator.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import UIKit

enum MainRoutes {
    case detailPage
}

protocol MainRouterProtocol {
    func navigate(_ route: MainRoutes)
}

final class MainRouter {
    
    weak var viewController: MainViewController?
    
    static func createModule() -> UITabBarController {
        
        let view = MainViewController()
        let interactor = MainInteractor()
        let router = MainRouter()
        
        let presenter = MainPresenter(
            view: view,
            interactor: interactor,
            router: router
        )
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        
        let homeVC = HomeRouter.createModule()
        let favoritesVC = FavoritesRouter.createModule()
        
        let homeNavigationController = UINavigationController(
            rootViewController: homeVC
        )
        
        let favoritesNavigationController = UINavigationController(
            rootViewController: favoritesVC
        )
        
        view.setViewControllers(
            [homeNavigationController, favoritesNavigationController],
            animated: false
        )
        presenter.viewDidLoad()
        return view
    }
}

extension MainRouter: MainRouterProtocol {
    func navigate(_ route: MainRoutes) {
        switch route {
        case .detailPage:
            break//TODO: go to detail page
        }
    }
}
