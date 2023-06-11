//
//  MainView.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import Foundation
import UIKit

protocol MainViewControllerProtocol: AnyObject {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MainViewController: MainViewControllerProtocol {
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
