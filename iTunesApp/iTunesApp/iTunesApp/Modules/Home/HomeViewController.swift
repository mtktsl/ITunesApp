//
//  ViewController.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import UIKit
import GridLayout

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
