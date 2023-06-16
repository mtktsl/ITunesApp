//
//  MainModuleCreator.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import UIKit

enum MainRoutes {
    case detailPage(_ data: SearchCellEntity?)
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
        let favoritesVC = FavoritesRouter.createModule(
            UIApplication.shared.delegate as? AppDelegate
        )
        
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
    
    func navigateToDetail(_ data: SearchCellEntity?) {
        let detailVC = DetailRouter.createModule(data)
        viewController?
            .navigationController?
            .pushViewController(detailVC, animated: true)
    }
}

extension MainRouter: MainRouterProtocol {
    func navigate(_ route: MainRoutes) {
        switch route {
        case .detailPage(let data):
            navigateToDetail(data)
        }
    }
}
