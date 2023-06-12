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
    
    func setupView()
    func setupFilterView()
    func setupSearchBar()
    func setupCollectionView()
    func setupMainGrid()
}

class HomeViewController: BaseViewController {

    var presenter: HomePresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
}

extension HomeViewController: HomeViewControllerProtocol {
    
    func setupView() {
        view.backgroundColor = .white
    }
    
    func setupSearchBar() {
        
    }
    
    func setupFilterView() {
        
    }
    
    func setupCollectionView() {
        
    }
    
    func setupMainGrid() {
        let segmentedPicker = SegmentedPickerView(
            segmentedFilters: ["All", "Music"],
            moreFilters: ["Album", "Movie"],
            moreButtonTitle: "More",
            moreButtonImage: .init(systemName: "line.3.horizontal.decrease")
        )
        let grid = Grid.vertical {
            segmentedPicker
                .Expanded(verticalAlignment: .constantTop(height: 50))
        }
        
        segmentedPicker.backgroundColor = UIColor(
            hue: 240.0/360.0,
            saturation: 0,
            brightness: 0.94,
            alpha: 1
        )
        segmentedPicker.popupCancelColor = .systemRed
        
        view.addSubview(grid)
        grid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.expand(grid, to: view.safeAreaLayoutGuide)
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
    
    
}
