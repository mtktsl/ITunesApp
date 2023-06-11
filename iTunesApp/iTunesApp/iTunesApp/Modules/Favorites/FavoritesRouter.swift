//
//  FavoritesRouter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation

protocol FavoritesRouterProtocol: AnyObject {
    
}

final class FavoritesRouter {
    
    weak var viewController: FavoritesViewController?
    
    static func createModule() -> FavoritesViewController {
        let view = FavoritesViewController()
        let interactor = FavoritesInteractor()
        let router = FavoritesRouter()
        let presenter = FavoritesPresenter(
            view: view,
            router: router,
            interactor: interactor
        )
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        
        view.title = "Favorites"
        
        return view
    }
}

extension FavoritesRouter: FavoritesRouterProtocol {
    
}
