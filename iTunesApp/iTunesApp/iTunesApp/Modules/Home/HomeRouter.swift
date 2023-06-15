//
//  HomeRouter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation

enum HomeRoutes {
    case detailPage
}

protocol HomeRouterProtocol: AnyObject {
    func navigate(_ route: HomeRoutes)
}

final class HomeRouter {
    
    weak var viewController: HomeViewController?
    
    static func createModule() -> HomeViewController {
        let view = HomeViewController()
        let interactor = HomeInteractor()
        let router = HomeRouter()
        let presenter = HomePresenter(
            view: view,
            router: router,
            interactor: interactor
        )
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        
        view.title = "iTunes"
        
        return view
    }
}

extension HomeRouter: HomeRouterProtocol {
    func navigate(_ route: HomeRoutes) {
        switch route {
        case .detailPage:
            let main = viewController?.navigationController?.tabBarController as? MainViewController
            main?.presenter.detailRequest()
        }
    }
}
