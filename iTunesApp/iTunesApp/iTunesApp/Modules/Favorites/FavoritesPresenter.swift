//
//  FavoritesPresenter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation

protocol FavoritesPresenterProtocol: AnyObject {
    
}

final class FavoritesPresenter {
    
    unowned var view: FavoritesViewControllerProtocol!
    let router: FavoritesRouterProtocol!
    let interactor: FavoritesInteractorProtocol!
    
    init(
        view: FavoritesViewControllerProtocol!,
        router: FavoritesRouterProtocol!,
        interactor: FavoritesInteractorProtocol!
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
}

extension FavoritesPresenter: FavoritesPresenterProtocol {
    
}

extension FavoritesPresenter: FavoritesInteractorOutputProtocol {
    
}
