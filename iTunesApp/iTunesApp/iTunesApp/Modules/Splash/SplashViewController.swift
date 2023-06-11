//
//  SplashViewController.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 11.06.2023.
//

import UIKit

protocol SplashViewControllerProtocol: AnyObject {
    func showError(
        title: String,
        message: String,
        okOption: String?,
        cancelOption: String?,
        onOk: ((UIAlertAction) -> Void)?,
        onCancel: ((UIAlertAction) -> Void)?
    )
}

final class SplashViewController: BaseViewController {
    
    var presenter: SplashPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
}

extension SplashViewController: SplashViewControllerProtocol {
    func showError(title: String,
                    message: String,
                    okOption: String?,
                    cancelOption: String?,
                    onOk: ((UIAlertAction) -> Void)?,
                    onCancel: ((UIAlertAction) -> Void)?) {
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
