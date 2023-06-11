//
//  BaseViewController.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import UIKit
import LoadingShowerController

class BaseViewController: UIViewController, LoadingShower {
   
    func popupError(
        title: String,
        message: String,
        okOption: String? = nil,
        cancelOption: String? = nil,
        onOk: ((UIAlertAction) -> Void)? = nil,
        onCancel: ((UIAlertAction) -> Void)? = nil
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
