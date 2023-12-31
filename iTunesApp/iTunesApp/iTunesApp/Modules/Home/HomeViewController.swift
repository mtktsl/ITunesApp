//
//  ViewController.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import UIKit
import GridLayout
import SegmentedPickerView

protocol HomeViewControllerProtocol: AnyObject {
    func showError(
        title: String,
        message: String,
        okOption: String?,
        cancelOption: String?,
        onOk: ((UIAlertAction) -> Void)?,
        onCancel: ((UIAlertAction) -> Void)?
    )
    
    //Setup functions
    func setupView()
    
    func setupFilterView(
        visibleFilters: [String],
        hiddenFilters: [String],
        moreButtonTitle: String,
        moreButtonImageName: String,
        pickerTitle: String
    )
    
    func setupSearchBar()
    func setupCollectionBackgroundView(
        warningMessage: String,
        imageSystemName: String
    )
    func setupCollectionView(_ layout: UICollectionViewFlowLayout)
    func setupMainGrid()
    //-------------------
    
    func reloadData()
    func toggleNotFound(_ isHidden: Bool)
    func showLoading()
    func hideLoading()
    func endEditting()
}

class HomeViewController: BaseViewController {

    var presenter: HomePresenterProtocol!
    
    var timer = Timer()
    var selectedFilter: String?
    
    var searchBar: UISearchBar!
    
    var segmentedPickerView: SegmentedPickerView!
    
    var emptySearchBackgroundView: UIView!
    
    var collectionView: UICollectionView!
    
    var mainGrid: Grid!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
}

extension HomeViewController: HomeViewControllerProtocol {
    func endEditting() {
        self.view.endEditing(true)
    }
    
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            collectionView.reloadData()
        }
    }
    
    func toggleNotFound(_ isHidden: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            emptySearchBackgroundView.isHidden = isHidden
        }
    }
    
    func setupView() {
        view.backgroundColor = .white
    }
    
    func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search"
    }
    
    func setupFilterView(
        visibleFilters: [String],
        hiddenFilters: [String],
        moreButtonTitle: String,
        moreButtonImageName: String,
        pickerTitle: String
    ) {
        segmentedPickerView = SegmentedPickerView.build(
            segmentedFilters: visibleFilters,
            moreFilters: hiddenFilters,
            moreButtonTitle: moreButtonTitle,
            moreButtonImage: UIImage(systemName: moreButtonImageName),
            pickerTitle: pickerTitle
        )
        segmentedPickerView.popupCancelColor = .systemRed
        segmentedPickerView.delegate = self
    }
    
    func setupCollectionBackgroundView(
        warningMessage: String,
        imageSystemName: String
    ) {
        let warningLabel = UILabel()
        warningLabel.text = warningMessage
        warningLabel.numberOfLines = 0
        warningLabel.textAlignment = .center
        
        let notFoundImageView = UIImageView(
            image: .init(systemName: imageSystemName)
        )
        notFoundImageView.contentMode = .scaleAspectFit
        
        emptySearchBackgroundView = Grid.vertical {
            notFoundImageView
                .Constant(value: 200)
            warningLabel
                .Auto(margin: .init(10))
        }
        
        emptySearchBackgroundView.isHidden = true
        
        collectionView.backgroundView = emptySearchBackgroundView
    }
    
    func setupCollectionView(_ layout: UICollectionViewFlowLayout) {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            SearchCell.self,
            forCellWithReuseIdentifier: SearchCell.reuseIdentifier
        )
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupMainGrid() {
        
        mainGrid = Grid.vertical {
            searchBar
                .Auto()
            segmentedPickerView
                .Auto(margin: .init(0,0, 10))
            collectionView
                .Expanded()
        }
        view.addSubview(mainGrid)
        mainGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.expand(mainGrid, to: view.safeAreaLayoutGuide)
    }
    
    func showError(
        title: String,
        message: String,
        okOption: String?,
        cancelOption: String?,
        onOk: ((UIAlertAction) -> Void)?,
        onCancel: ((UIAlertAction) -> Void)?
    ) {
        popupError(
            title: title,
            message: message,
            okOption: okOption,
            cancelOption: cancelOption,
            onOk: onOk,
            onCancel: onCancel
        )
    }
    
    func showLoading() {
        super.showLoading(on: collectionView)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //presenter.searchDidChange(searchText)
        presenter.onSearchUpdate(
            searchText: searchText,
            filter: segmentedPickerView.currentSelection ?? ""
        )
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

extension HomeViewController: SegmentedPickerViewDelegate {
    func onSelectionChanged(_ newSelection: String) {
        //selectedFilter = newSelection
        //presenter.filterDidChange(newSelection)
        presenter.onSearchUpdate(
            searchText: searchBar.text ?? "",
            filter: newSelection
        )
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return presenter.numberOfItems
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchCell.reuseIdentifier,
            for: indexPath
        ) as? SearchCell
        else {
            fatalError("Failed to cast search cell in HomeViewController.")
        }

        cell.presenter = SearchCellPresenter(
            view: cell,
            interactor: SearchCellInteractor(),
            data: presenter.getSearchResult(at: indexPath.row)
        )
        cell.delegate = self
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        presenter.didSelectItem(at: indexPath.row)
    }
}

extension HomeViewController: SearchCellDelegate {
    func onPlayButtonTap(
        _ urlString: String,
        title: String?
    ) {
        presenter.onPlayTap(
            urlString,
            title: title
        )
    }
}

