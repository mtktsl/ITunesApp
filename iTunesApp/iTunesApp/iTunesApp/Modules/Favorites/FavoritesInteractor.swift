//
//  FavoritesInteractor.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation

protocol FavoritesInteractorProtocol: AnyObject {
    
}

protocol FavoritesInteractorOutputProtocol {
    
}

final class FavoritesInteractor {
    var output: FavoritesInteractorOutputProtocol!
}

extension FavoritesInteractor: FavoritesInteractorProtocol {
    
}
