//
//  FavoritesRouter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import UIKit

enum FavoritesRoutes {
    case detailPage(_ data: SearchCellEntity?)
    case mediaPlayer(_ urlString: String?)
}

protocol FavoritesRouterProtocol: AnyObject {
    func navigate(_ route: FavoritesRoutes)
}

final class FavoritesRouter {
    
    weak var viewController: FavoritesViewController?
    
    static func createModule(_ appDelegate: AppDelegate?) -> FavoritesViewController {
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
        interactor.appDelegate = appDelegate
        router.viewController = view
        
        view.title = "Favorites"
        
        return view
    }
}

extension FavoritesRouter: FavoritesRouterProtocol {
    func navigate(_ route: FavoritesRoutes) {
        
        switch route {
        case .detailPage(let data):
            let main = viewController?.navigationController?.tabBarController as? MainViewController
            main?.presenter.detailRequest(data)
        case .mediaPlayer(let urlString):
            guard let viewController else { return }
            MediaPlayer.shared.play(urlString, viewController: viewController)
        }
    }
}
