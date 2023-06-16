//
//  FavoritesViewController.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import UIKit
import GridLayout

protocol FavoritesViewControllerProtocol: AnyObject {
    func setupView()
    func reloadData()
    func showLoading()
    func endEditting()
}

final class FavoritesViewController: BaseViewController {
    
    var presenter: FavoritesPresenterProtocol!
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        return searchBar
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = SearchCollectionFlowLayout(
            maxNumColumns: 1,
            cellHeight: .searchCellHomeHeight
        )
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            SearchCell.self,
            forCellWithReuseIdentifier: SearchCell.reuseIdentifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    lazy var mainGrid = Grid.vertical {
        searchBar
            .Auto()
        collectionView
            .Expanded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
}

extension FavoritesViewController: FavoritesViewControllerProtocol {
    func endEditting() {
        self.isEditing = false
    }
    
    func setupView() {
        view.backgroundColor = .white
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainGrid)
        NSLayoutConstraint.expand(mainGrid, to: view.safeAreaLayoutGuide)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func showLoading() {
        super.showLoading(on: collectionView)
    }
}

extension FavoritesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchCell.reuseIdentifier,
            for: indexPath
        ) as? SearchCell
        else {
            fatalError("Failed to cast searchCell in Favorites Page")
        }
        
        guard let data = presenter.getSearch(at: indexPath.row)
        else { fatalError("Index error for searchCell in Favorites Page") }
        
        cell.presenter = SearchCellPresenter(
            view: cell,
            interactor: SearchCellInteractor(),
            data: data
        )
        
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath.row)
    }
}

extension FavoritesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.onSearchDidChange(searchText)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.onReturnTap()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.onReturnTap()
    }
}

extension FavoritesViewController: SearchCellDelegate {
    func onPlayButtonTap(_ urlString: String) {
        presenter.onPlayTap(urlString)
    }
}
