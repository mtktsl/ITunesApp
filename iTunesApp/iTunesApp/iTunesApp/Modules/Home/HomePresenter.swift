//
//  HomePresenter.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation

extension HomePresenter {
    fileprivate enum Constants {
        static let connectionErrorTitle = "Connection Error"
        static let connectionErrorMessage = "There is no internet connection."
        static let connectionErrorOkOption = "Retry"
    }
}

protocol HomePresenterProtocol: AnyObject {
    func testQuery()
    
    func viewDidLoad()
}

final class HomePresenter {
    unowned var view: HomeViewControllerProtocol!
    let router: HomeRouterProtocol!
    let interactor: HomeInteractorProtocol!
    
    var isPopupOpen = false
    
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
    func viewDidLoad() {
        
        interactor.testQuery()
        
        view.setupView()
        view.setupSearchBar()
        view.setupFilterView()
        view.setupCollectionView()
        view.setupMainGrid()
    }
    
    func testQuery() {
        interactor.testQuery()
    }
}

extension HomePresenter: HomeInteractorOutputProtocol {
    
}
