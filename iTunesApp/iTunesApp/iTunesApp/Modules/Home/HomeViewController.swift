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
    func setupCollectionView()
    func setupMainGrid()
    //-------------------
    
    func reloadData()
    func startSearchUpdates()
    func showLoading()
    func hideLoading()
}

class HomeViewController: BaseViewController {

    var presenter: HomePresenterProtocol!
    
    var timer = Timer()
    var selectedFilter: String?
    
    var searchBar: UISearchBar!
    
    var segmentedPickerView: SegmentedPickerView!
    
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
    
    func startSearchUpdates() {
        self.timer = Timer.scheduledTimer(
            withTimeInterval: 1.5,
            repeats: true,
            block: { [weak self] _ in
                guard let self else { return }
                presenter.onSearchUpdate(
                    searchText: searchBar.text ?? "",
                    filter: selectedFilter
                    ?? ApplicationConstants
                        .AvailableFilters.all.rawValue
                )
            }
        )
    }
    
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            collectionView.reloadData()
        }
    }
    
    
    func setupView() {
        view.backgroundColor = .white
    }
    
    func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        //searchBar.placeholder = presenter.getPlaceHolder()
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
    
    func setupCollectionView() {
        let layout = SearchCollectionFlowLayout(
            maxNumColumns: 1,
            cellHeight: 80
        )
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
        
        let imageView = UIImageView(image: UIImage(systemName: "star"))
        imageView.contentMode = .scaleAspectFit
        
        let filterGrid = Grid.horizontal {
            imageView
                .Auto()
            segmentedPickerView
                .Expanded()
        }
        
        mainGrid = Grid.vertical {
            searchBar
                .Auto()
            filterGrid
                .Constant(value: 35)
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
        let frame = CGRect(
            x: CGFloat(mainGrid.frame.origin.x + collectionView.frame.origin.x),
            y: CGFloat(mainGrid.frame.origin.y + collectionView.frame.origin.y),
            width: collectionView.bounds.size.width,
            height: collectionView.bounds.size.height
        )
        
        super.showLoading(frame)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}

extension HomeViewController: SegmentedPickerViewDelegate {
    func onSelectionChanged(_ newSelection: String) {
        selectedFilter = newSelection
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
        
        let data = presenter.getSearchResult(at: indexPath.row)
        
        cell.presenter = SearchCellPresenter(
            view: cell,
            interactor: SearchCellInteractor(),
            data: .init(
                trackName: data?.trackName,
                artistName: data?.artistName,
                collectionName: data?.collectionName,
                imageURLString: data?.artworkUrl100
                                ?? data?.artworkUrl60
                                ?? data?.artworkUrl30,
                previewURLString: data?.previewUrl)
        )
        
        return cell
    }
}
