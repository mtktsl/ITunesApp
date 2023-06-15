//
//  SearchCellPresenter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 14.06.2023.
//

import Foundation

extension SearchCellPresenter {
    enum Constants {
        static let defaultImageName = "loading"
        static let errorImageName = "exclamationmark.triangle"
    }
}

protocol SearchCellPresenterProtocol: AnyObject {
    func cellDidInit()
    func cellDidSetup()
}

final class SearchCellPresenter {
    unowned var view: SearchCellProtocol!
    let interactor: SearchCellInteractor!
    let data: SearchCellEntity
    
    init(
        view: SearchCellProtocol!,
        interactor: SearchCellInteractor!,
        data: SearchCellEntity
    ) {
        self.view = view
        self.interactor = interactor
        self.data = data
        self.interactor.output = self
    }
}

extension SearchCellPresenter: SearchCellPresenterProtocol {
    func cellDidSetup() {
        interactor.fetchImage(data.imageURLString ?? "")
    }
    
    func cellDidInit() {
        view.setupCell(
            title: data.trackName,
            subtitle: data.artistName,
            body: data.collectionName
        )
        view.setupImage(imageName: Constants.defaultImageName)
    }
}

extension SearchCellPresenter: SearchCellInteractorOutputProtocol {
    func onImageResult(_ data: Data?) {
        if let data {
            view.setupImage(data: data)
        } else {
            view.setupImage(systemName: Constants.errorImageName)
        }
    }
}
