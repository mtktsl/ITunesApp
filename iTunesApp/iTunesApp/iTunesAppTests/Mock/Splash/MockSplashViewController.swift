//
//  MockSplashViewController.swift
//  iTunesAppTests
//
//  Created by Metin Tarık Kiki on 16.06.2023.
//

import Foundation
@testable import iTunesApp
import UIKit

final class MockSplashViewController: SplashViewControllerProtocol {
    
    var presenter: SplashPresenterProtocol!
    
    var showErrorInvoke = false
    var showErrorCount = 0
    
    func showError(title: String, message: String, okOption: String?, cancelOption: String?, onOk: ((UIAlertAction) -> Void)?, onCancel: ((UIAlertAction) -> Void)?) {
        showErrorInvoke = true
        showErrorCount += 1
    }
    
    var didAppearInvoke = false
    var didAppearCount = 0
    
    func didAppear() {
        didAppearInvoke = true
        didAppearCount += 1
        presenter.viewDidAppear()
    }
}
