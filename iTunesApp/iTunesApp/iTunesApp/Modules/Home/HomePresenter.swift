//
//  HomePresenter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import iTunesAPI // <- Web result model is defined in the API

extension HomePresenter {
    fileprivate enum Constants {
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
    func onPlayTap(_ urlString: String?)
    func onReturnTap()
}

final class HomePresenter {
    unowned var view: HomeViewControllerProtocol!
    let router: HomeRouterProtocol!
    let interactor: HomeInteractorProtocol!
    
    var isPopupOpen = false
    
    var searchResults = [ITunesResultModel]()
    var lastSearch: String?
    var lastFilter: String?
    
    init(
        view: HomeViewControllerProtocol,
        router: HomeRouterProtocol,
        interactor: HomeInteractorProtocol
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
}

extension HomePresenter: HomePresenterProtocol {
    func onReturnTap() {
        view.endEditting()
    }
    
    func onPlayTap(_ urlString: String?) {
        view.endEditting()
        router.navigate(.mediaPlayer(urlString))
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
    }
    
    func searchDidChange(_ text: String) {
        view.showLoading()
    }
    
    func viewDidAppear() {
        interactor.reloadCoreData()
        view.startSearchUpdates(Constants.searchInterval)
    }
    
    
    func onSearchUpdate(
        searchText: String,
        filter: String
    ) {
        if lastSearch == searchText && lastFilter == filter {
            view.hideLoading()
            return
        }
        lastSearch = searchText
        lastFilter = filter
        
        guard !searchText.isEmpty else {
            view.hideLoading()
            return
        }
        interactor.performQuery(
            searchText: searchText,
            filter: filter
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
        
        view.setupMainGrid()
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
    }
}
