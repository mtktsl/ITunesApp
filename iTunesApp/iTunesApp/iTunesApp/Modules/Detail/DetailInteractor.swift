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
    
    func onCoreDataResult(result: DetailEntity.CoreDataResult)
}

final class DetailInteractor {
    var output: DetailInteractorOutputProtocol!
    let webService: iTunesAPIProtocol = iTunesAPI()
    var coreDataService: CoreDataManagerProtocol = CoreDataManager.shared
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
        if coreDataService.addFavorite(data) {
            output.onCoreDataResult(result: .success)
        } else {
            output.onCoreDataResult(result: .failure(error: .addFailure))
        }
    }
    
    func removeFavorite(_ data: SearchCellEntity) {
        if coreDataService.removeFavorite(data) {
            output.onCoreDataResult(result: .success)
        } else {
            output.onCoreDataResult(result: .failure(error: .removeFailure))
        }
    }
    
    func downloadImage(_ urlString: String?) {
        
        guard let urlString else {
            output.onImageError()
            return
        }
        
        imageDataTask = webService.fetchImage(urlString) { [weak self] result in
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
