//
//  FavoritesViewController.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import UIKit

protocol FavoritesViewControllerProtocol: AnyObject {
    
}

final class FavoritesViewController: BaseViewController {
    
    var presenter: FavoritesPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

extension FavoritesViewController: FavoritesViewControllerProtocol {
    
}
