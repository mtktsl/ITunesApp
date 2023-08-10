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
    
    enum PopupMessages {
        static let coreDataErrorTitle = "Favorite Toggle Error"
        static let coreDataErrorMessage = "Something went wrong. Please restart your app."
        static let coreDataErrorOkOption = "OK"
        
        static let coreDataSuccessTitle = "Favorite Toggle Success"
        static let coreDataSuccessMessage = "Favorite status has been successfully changed."
        static let coreDataSuccessOkOption = "OK"
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
    var mediaPlayer: MediaPlayerProtocol
    
    private(set) var data: SearchCellEntity?
    
    init(
        view: DetailViewControllerProtocol!,
        interactor: DetailInteractorProtocol!,
        router: DetailRouterProtocol!,
        data: SearchCellEntity?,
        mediaPlayer: MediaPlayerProtocol = MediaPlayer.shared
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.data = data
        self.mediaPlayer = mediaPlayer
    }
    
    private func generateCoreDataErrorPopup() {
        view.showPopup(
            title: PopupMessages.coreDataErrorTitle,
            message: PopupMessages.coreDataErrorMessage,
            okOption: PopupMessages.coreDataErrorOkOption,
            cancelOption: nil,
            onOk: nil,
            onCancel: nil
        )
    }
    
    private func generateCoreDataSuccessPopup() {
        view.showPopup(
            title: PopupMessages.coreDataSuccessTitle,
            message: PopupMessages.coreDataSuccessMessage,
            okOption: PopupMessages.coreDataSuccessOkOption,
            cancelOption: nil,
            onOk: nil,
            onCancel: nil
        )
    }
}

extension DetailPresenter: DetailPresenterProtocol {
    func onPlayTap() {
        mediaPlayer.play(
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
    func onCoreDataResult(result: DetailEntity.CoreDataResult) {
        switch result {
        case .success:
            generateCoreDataSuccessPopup()
        case .failure(_):
            generateCoreDataErrorPopup()
        }
    }
    
    func onImageSuccess(_ data: Data) {
        view.setupImageView(data)
    }
    
    func onImageError() {
        view.setupImageView(
            systemName: ApplicationConstants.SystemImageNames.exclamationMarkTriangle
        )
    }
}
