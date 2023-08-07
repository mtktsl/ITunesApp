//
//  DetailPresenter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 15.06.2023.
//

import Foundation
import FloatingViewManager

extension DetailPresenter {
    enum Constants {
        static let pauseButtonImageName = "pause.fill"
        static let playButtonImageName = "play.circle"
        static let heartEmptyImageName = "heart"
        static let heartFillImageName = "heart.fill"
        
        static let favRemoveTitle = "Warning!"
        static let favRemoveMessage = "You are about to remove this from favorites."
        static let favRemoveOkOption = "Confirm"
        static let favRemoveCancelOption = "Cancel"
        
        static let floatingPlayerStartupLocation: FloatingViewManager.FloatingLocation = .bottomLeft
        static let floatingPlayerPipSize = CGSize(width: 180, height: 101.25)
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
        MediaPlayer.shared.play(
            data?.previewURLString,
            playingTitle: data?.trackName,
            startUpLocation: Constants.floatingPlayerStartupLocation,
            floatingSize: Constants.floatingPlayerPipSize
        )
    }
    
    func onFavTap() {
        if let favData = data {
            if !favData.isFavorite {
                interactor.addFavorite(favData)
                view.setupFavImageView(systemName: Constants.heartFillImageName)
                data?.isFavorite.toggle()
            } else {
                
                view.showPopup(
                    title: Constants.favRemoveTitle,
                    message: Constants.favRemoveMessage,
                    okOption: Constants.favRemoveOkOption,
                    cancelOption: Constants.favRemoveCancelOption,
                    onOk: { [weak self] _ in
                        guard let self else { return }
                        interactor.removeFavorite(favData)
                        view.setupFavImageView(systemName: Constants.heartEmptyImageName)
                        data?.isFavorite.toggle()
                    },
                    onCancel: nil
                )
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
            systemName: ApplicationConstants.SystemImageNames.exclamationMarkTriangle
        )
    }
}
