//
//  FavoritesInteractor.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import iTunesAPI

protocol FavoritesInteractorProtocol: AnyObject {
    func fetchFavorites()
}

protocol FavoritesInteractorOutputProtocol {
    func onFavoritesResult(_ data: [SearchCellEntity])
}

final class FavoritesInteractor {
    var output: FavoritesInteractorOutputProtocol!
    var appDelegate: AppDelegate!
    var coreDataService: CoreDataManagerProtocol = CoreDataManager.shared
}

extension FavoritesInteractor: FavoritesInteractorProtocol {
    func fetchFavorites() {
        let data = coreDataService.fetchFavorites()
        output.onFavoritesResult(data)
    }
}
