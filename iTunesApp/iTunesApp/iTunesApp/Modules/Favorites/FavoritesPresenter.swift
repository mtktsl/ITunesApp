//
//  FavoritesPresenter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import FloatingViewManager

extension FavoritesPresenter {
    fileprivate enum Constants {
        static let floatingPlayerStartupLocation: FloatingViewManager.FloatingLocation = .bottomLeft
        static let floatingPlayerPipSize = CGSize(width: 180, height: 101.25)
    }
}

protocol FavoritesPresenterProtocol: AnyObject {
    
    var itemCount: Int { get }
    
    func viewDidLoad()
    func viewWillAppear()
    func onSearchDidChange(_ searchText: String?)
    func getSearch(at index: Int) -> SearchCellEntity?
    func didSelectItem(at index: Int)
    func onPlayTap(
        _ urlString: String?,
        title: String?
    )
    func onReturnTap()
}

final class FavoritesPresenter {
    
    unowned var view: FavoritesViewControllerProtocol!
    let router: FavoritesRouterProtocol!
    let interactor: FavoritesInteractorProtocol!
    
    var collection = [SearchCellEntity]()
    var filteredCollection = [SearchCellEntity]()
    var isFiltering = false
    var mediaPlayer: MediaPlayerProtocol
    
    init(
        view: FavoritesViewControllerProtocol!,
        router: FavoritesRouterProtocol!,
        interactor: FavoritesInteractorProtocol!,
        mediaPlayer: MediaPlayerProtocol = MediaPlayer.shared
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.mediaPlayer = mediaPlayer
    }
}

extension FavoritesPresenter: FavoritesPresenterProtocol {
    func onReturnTap() {
        view.endEditting()
    }
    
    func onPlayTap(
        _ urlString: String?,
        title: String?
    ) {
        view.endEditting()
        mediaPlayer.play(
            urlString,
            playingTitle: title,
            startUpLocation: Constants.floatingPlayerStartupLocation,
            floatingSize: Constants.floatingPlayerPipSize
        )
    }
    
    func didSelectItem(at index: Int) {
        guard let data = getSearch(at: index)
        else { return }
        router.navigate(.detailPage(data))
        view.endEditting()
    }
    
    
    var itemCount: Int {
        return isFiltering
        ? filteredCollection.count
        : collection.count
    }
    
    func viewDidLoad() {
        view.setupView()
    }
    
    func viewWillAppear() {
        interactor.fetchFavorites()
    }
    
    func onSearchDidChange(_ searchText: String?) {
        isFiltering = !(searchText ?? "").isEmpty
        guard let searchText else {
            view.reloadData()
            return
        }
        
        if isFiltering {
            filteredCollection = collection.filter {
                ($0.trackName?.contains(searchText) ?? false)
                || ($0.artistName?.contains(searchText) ?? false)
                || ($0.collectionName?.contains(searchText) ?? false)
                || ($0.primaryGenreName?.contains(searchText) ?? false)
            }
        }
        view.reloadData()
    }
    
    func getSearch(at index: Int) -> SearchCellEntity? {
        if index >= itemCount || index < 0 {
            return nil
        } else {
            return isFiltering
            ? filteredCollection[index]
            : collection[index]
        }
    }
}

extension FavoritesPresenter: FavoritesInteractorOutputProtocol {
    func onFavoritesResult(_ data: [SearchCellEntity]) {
        collection = data
        view.reloadData()
    }
}
