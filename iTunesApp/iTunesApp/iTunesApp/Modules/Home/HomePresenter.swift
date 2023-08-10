//
//  HomePresenter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import iTunesAPI // <- Web result model is defined in the API
import FloatingViewManager

extension HomePresenter {
    fileprivate enum Constants {
        static let notFoundMessage = "There is no result for the search entry."
        static let connectionErrorTitle = "Connection Error"
        static let connectionErrorMessage = "There is no internet connection."
        static let connectionErrorOkOption = "Retry"
        static let visibleFilterCount = 2
        static let filterMoreButtonTitle = "More"
        static let filterMoreButtonImage = "line.3.horizontal.decrease"
        static let filterMoreTitle = "Select Filter"
        static let collectionLayout = SearchCollectionFlowLayout(
            maxNumColumns: 1,
            cellHeight: .searchCellHomeHeight
        )
        // api docs says that the api is limited to aprox. 20 searches per minute
        // since the user is not going to edit text for 60 seconds straight
        // limiting the application search interval to max 30 per a min. would work fine
        static let searchInterval: Double = 2
        
        static let floatingPlayerStartupLocation: FloatingViewManager.FloatingLocation = .bottomLeft
        static let floatingPlayerPipSize = CGSize(width: 180, height: 101.25)
    }
}

protocol HomePresenterProtocol: AnyObject {
    
    var numberOfItems: Int { get }
    
    func viewDidLoad()
    func getSearchResult(at index: Int) -> SearchCellEntity
    func onSearchUpdate(
        searchText: String,
        filter: String
    )
    
    func viewDidAppear()
    func searchDidChange(_ text: String)
    func filterDidChange(_ filter: String)
    func didSelectItem(at index: Int)
    func onPlayTap(
        _ urlString: String?,
        title: String?
    )
    func onReturnTap()
    func onViewTap()
}

final class HomePresenter {
    unowned var view: HomeViewControllerProtocol!
    let router: HomeRouterProtocol!
    let interactor: HomeInteractorProtocol!
    var floatingViewManager: FloatingViewManagerProtocol
    var mediaPlayer: MediaPlayerProtocol
    
    var isPopupOpen = false
    
    var searchResults = [ITunesResultModel]()
    var lastSearch: String?
    var lastFilter: String?
    
    init(
        view: HomeViewControllerProtocol,
        router: HomeRouterProtocol,
        interactor: HomeInteractorProtocol,
        floatingViewManager: FloatingViewManagerProtocol = FloatingViewManager.shared,
        mediaPlayer: MediaPlayerProtocol = MediaPlayer.shared
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.floatingViewManager = floatingViewManager
        self.mediaPlayer = mediaPlayer
    }
}

extension HomePresenter: HomePresenterProtocol {
    func onViewTap() {
        view.endEditting()
    }
    
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
        if index < 0 || index > numberOfItems {
            return
        }
        let data = searchResults[index]
        router.navigate(
            .detailPage(interactor.apiToEntity(data))
        )
    }
    
    
    func filterDidChange(_ filter: String) {
        view.showLoading()
        floatingViewManager.bringViewToFront()
    }
    
    func searchDidChange(_ text: String) {
        view.showLoading()
        floatingViewManager.bringViewToFront()
    }
    
    func viewDidAppear() {
        interactor.reloadCoreData()
        //view.startSearchUpdates(Constants.searchInterval)
    }
    
    
    func onSearchUpdate(
        searchText: String,
        filter: String
    ) {
        view.showLoading()
        floatingViewManager.bringViewToFront()
        
        interactor.performQuery(
            searchText: searchText,
            filterText: filter
        )
    }
    
    
    var numberOfItems: Int {
        return searchResults.count
    }
    
    func viewDidLoad() {
        view.setupView()
        view.setupSearchBar()
        
        let filters = interactor.createFilters()
        
        view.setupFilterView(
            visibleFilters: filters.visibleFilters,
            hiddenFilters: filters.hiddenFilters,
            moreButtonTitle: Constants.filterMoreButtonTitle,
            moreButtonImageName: Constants.filterMoreButtonImage,
            pickerTitle: Constants.filterMoreTitle
        )
        
        view.setupCollectionView(
            Constants.collectionLayout
        )
        
        view.setupCollectionBackgroundView(
            warningMessage: Constants.notFoundMessage,
            imageSystemName: ApplicationConstants.SystemImageNames.textMagnifyingGlass
        )
        
        view.setupMainGrid()
        view.toggleNotFound(false)
    }
    
    func getSearchResult(at index: Int) -> SearchCellEntity {
        let data = searchResults[index]
        return interactor.apiToEntity(data)
    }
}

extension HomePresenter: HomeInteractorOutputProtocol {
    func onSearchResult(_ data: [ITunesResultModel], forText: String, forFilter: String) {
        
        searchResults = data
        
        lastSearch = forText
        lastFilter = forFilter
        
        view.reloadData()
        view.hideLoading()
        
        view.toggleNotFound(!data.isEmpty)
    }
}
