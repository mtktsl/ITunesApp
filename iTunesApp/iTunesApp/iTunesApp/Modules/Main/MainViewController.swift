//
//  MainView.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import UIKit

protocol MainViewControllerProtocol: AnyObject {
    
    func setupTabBar(imageNames: [String])
    
    func showError(
        title: String,
        message: String,
        okOption: String?,
        cancelOption: String?,
        onOk: ((AnyObject) -> Void)?,
        onCancel: ((AnyObject) -> Void)?
    )
}

final class MainViewController: UITabBarController {
    var presenter: MainPresenterProtocol!
}

extension MainViewController: MainViewControllerProtocol {
    func setupTabBar(imageNames: [String]) {
        
        guard let items = self.tabBar.items else { return }
        for i in 0 ..< items.count {
            items[i].image = UIImage(systemName: imageNames[i])
        }
        tabBar.backgroundColor = .tabBarColor
    }
    
    func showError(
        title: String,
        message: String,
        okOption: String?,
        cancelOption: String?,
        onOk: ((AnyObject) -> Void)?,
        onCancel: ((AnyObject) -> Void)?
    ) {
        let alertVC = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: okOption ?? "OK",
            style: .default,
            handler: onOk
        )
        alertVC.addAction(okAction)
        
        if let cancelOption {
            let exitAction = UIAlertAction(
                title: cancelOption,
                style: .destructive,
                handler: onCancel
            )
            alertVC.addAction(exitAction)
        }
        
        present(alertVC, animated: true)
    }
}
