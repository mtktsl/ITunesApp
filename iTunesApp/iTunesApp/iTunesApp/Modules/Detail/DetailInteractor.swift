//
//  DetailInteractor.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 15.06.2023.
//

import Foundation
import iTunesAPI

protocol DetailInteractorProtocol {
    func downloadImage(_ urlString: String?)
    func addFavorite(_ data: SearchCellEntity)
    func removeFavorite(_ data: SearchCellEntity)
    func isFavorite(_ data: SearchCellEntity) -> Bool
}

protocol DetailInteractorOutputProtocol {
    func onImageSuccess(_ data: Data)
    func onImageError()
}

final class DetailInteractor {
    var output: DetailInteractorOutputProtocol!
    let service: iTunesAPIProtocol = iTunesAPI()
    var imageDataTask: URLSessionDataTask?
    deinit {
        imageDataTask?.cancel()
    }
}

extension DetailInteractor: DetailInteractorProtocol {
    func isFavorite(_ data: SearchCellEntity) -> Bool {
        return CoreDataManager.shared.exists(data)
    }
    
    func addFavorite(_ data: SearchCellEntity) {
        CoreDataManager.shared.addFavorite(data)
    }
    
    func removeFavorite(_ data: SearchCellEntity) {
        CoreDataManager.shared.removeFavorite(data)
    }
    
    func downloadImage(_ urlString: String?) {
        
        guard let urlString else {
            output.onImageError()
            return
        }
        
        imageDataTask = service.fetchImage(urlString) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                output.onImageSuccess(data)
            case .failure(_):
                output.onImageError()
            }
        }
    }
}
