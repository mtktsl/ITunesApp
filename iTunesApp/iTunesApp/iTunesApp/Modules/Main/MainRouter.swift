//
//  MainModuleCreator.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import UIKit

final class MainRouter {
    
    static func createModule() -> UITabBarController {
        
        let view = MainViewController()
        let interactor = MainInteractor()
        
        let presenter = MainPresenter(
            view: view,
            interactor: interactor
        )
        view.presenter = presenter
        interactor.output = presenter
        
        let homeVC = HomeRouter.createModule()
        let favoritesVC = FavoritesRouter.createModule()
        
        let homeNavigationController = UINavigationController(
            rootViewController: homeVC
        )
        
        let favoritesNavigationController = UINavigationController(
            rootViewController: favoritesVC
        )
        
        view.setViewControllers(
            [homeNavigationController, favoritesNavigationController],
            animated: false
        )
        
        if let items = view.tabBar.items {
            items[0].image = UIImage(systemName: "music.note.house")
            items[1].image = UIImage(systemName: "heart")
        }
        
        return view
    }
}
