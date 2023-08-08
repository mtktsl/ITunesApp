//
//  SearchCellInteractor.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 14.06.2023.
//

import Foundation
import iTunesAPI

protocol SearchCellInteractorProtocol: AnyObject {
    func fetchImage(_ urlString: String)
}

protocol SearchCellInteractorOutputProtocol: AnyObject {
    func onImageResult(_ data: Data?)
}

final class SearchCellInteractor {
    var output: SearchCellInteractorOutputProtocol!
    var service: iTunesAPIProtocol = iTunesAPI()
}


extension SearchCellInteractor: SearchCellInteractorProtocol {
    func fetchImage(_ urlString: String) {
        service.fetchImage(
            urlString
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                output.onImageResult(data)
            case .failure(_):
                output.onImageResult(nil)
            }
        }
    }
}
