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
}

extension FavoritesInteractor: FavoritesInteractorProtocol {
    func fetchFavorites() {
        let data = CoreDataManager.shared.fetchFavorites()
        output.onFavoritesResult(data)
    }
}
