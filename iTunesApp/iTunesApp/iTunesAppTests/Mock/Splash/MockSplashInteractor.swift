//
//  SplashInteractor.swift
//  iTunesAppTests
//
//  Created by Metin Tarık Kiki on 16.06.2023.
//

import Foundation
@testable import iTunesApp

final class MockSplashInteractor: SplashInteractorProtocol {
    
    var checkInternetInvoke = false
    var checkInternetCount = 0
    
    func checkInternetConnection() {
        checkInternetInvoke = true
        checkInternetCount += 1
        output.onInternetResult(false)
    }
    
    var outputInitInvoke = false
    var outputInitCount = 0
    
    var output: SplashInteractorOutputProtocol! {
        didSet {
            outputInitInvoke = true
            outputInitCount += 1
        }
    }
}
