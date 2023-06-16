//
//  DetailPresenter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 15.06.2023.
//

import Foundation

extension DetailPresenter {
    enum Constants {
        static let pauseButtonImageName = "pause.fill"
        static let playButtonImageName = "play.fill"
        static let heartEmptyImageName = "heart"
        static let heartFillImageName = "heart.fill"
    }
}

protocol DetailPresenterProtocol {
    func viewDidLoad()
    func viewDidAppear()
    func onFavTap()
    func onPlayTap()
}

final class DetailPresenter {
    unowned var view: DetailViewControllerProtocol!
    let interactor: DetailInteractorProtocol!
    let router: DetailRouterProtocol!
    
    private(set) var data: SearchCellEntity?
    
    init(
        view: DetailViewControllerProtocol!,
        interactor: DetailInteractorProtocol!,
        router: DetailRouterProtocol!,
        data: SearchCellEntity?
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.data = data
    }
}

extension DetailPresenter: DetailPresenterProtocol {
    func onPlayTap() {
        router.navigate(.mediaPlayer(urlString: data?.previewURLString))
    }
    
    func onFavTap() {
        data?.isFavorite.toggle()
        if let data {
            if data.isFavorite {
                interactor.addFavorite(data)
                view.setupFavImageView(systemName: Constants.heartFillImageName)
            } else {
                interactor.removeFavorite(data)
                view.setupFavImageView(systemName: Constants.heartEmptyImageName)
            }
        }
    }
    
    
    func viewDidLoad() {
        view.setupView()
        view.setupLabels(
            trackName: data?.trackName,
            artistName: data?.artistName,
            collectionName: data?.collectionName,
            genre: data?.primaryGenreName,
            trackPrice: data?.trackPrice,
            collectionPrice: data?.collectionPrice,
            currency: data?.currency
        )
        
        view.setupButtonImageView(systemName: Constants.playButtonImageName)
        view.setupFavImageView(
            systemName: data?.isFavorite ?? false
            ? Constants.heartFillImageName
            : Constants.heartEmptyImageName
        )
        
        interactor.downloadImage(
            data?.imageURLString
        )
    }
    
    func viewDidAppear() {
        view.showLoading()
    }
    
}

extension DetailPresenter: DetailInteractorOutputProtocol {
    func onImageSuccess(_ data: Data) {
        view.setupImageView(data)
    }
    
    func onImageError() {
        view.setupImageView(
            systemName: ApplicationConstants.ImageAssets.error.rawValue
        )
    }
}
