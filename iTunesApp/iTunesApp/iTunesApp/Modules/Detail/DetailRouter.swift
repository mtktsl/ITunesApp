//
//  DetailRouter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 15.06.2023.
//

import Foundation

enum DetailRoutes {
    case mediaPlayer(urlString: String?)
}

protocol DetailRouterProtocol {
    func navigate(_ route: DetailRoutes)
}

final class DetailRouter {
    weak var viewController: DetailViewController?
    
    static func createModule(_ data: SearchCellEntity?) -> DetailViewController {
        let view = DetailViewController()
        let interactor = DetailInteractor()
        let router = DetailRouter()
        let presenter = DetailPresenter(
            view: view,
            interactor: interactor,
            router: router,
            data: data
        )
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
}

extension DetailRouter: DetailRouterProtocol {
    func navigate(_ route: DetailRoutes) {
        switch route {
        case .mediaPlayer(let urlString):
            guard let viewController else { return }
            MediaPlayer.shared.play(urlString, viewController: viewController)
        }
    }
}
