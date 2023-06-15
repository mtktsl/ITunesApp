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
    }
}

protocol HomePresenterProtocol: AnyObject {
    
    var numberOfItems: Int { get }
    
    func viewDidLoad()
    func getSearchResult(at index: Int) -> ITunesResultModel?
    func onSearchUpdate(
        searchText: String,
        filter: String
    )
    
    func viewDidAppear()
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
    func viewDidAppear() {
        view.startSearchUpdates()
    }
    
    
    func onSearchUpdate(
        searchText: String,
        filter: String
    ) {
        if lastSearch == searchText && lastFilter == filter {
            return
        }
        lastSearch = searchText
        lastFilter = filter
        
        guard !searchText.isEmpty else { return }
        view.showLoading()
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
        
        view.setupCollectionView()
        view.setupMainGrid()
    }
    
    func getSearchResult(
        at index: Int
    ) -> ITunesResultModel? {
        if index >= numberOfItems || index < 0 {
            return nil
        } else {
            return searchResults[index]
        }
    }
}

extension HomePresenter: HomeInteractorOutputProtocol {
    func onSearchResult(_ data: [ITunesResultModel]) {
        self.searchResults = data
        view.reloadData()
        view.hideLoading()
    }
}
