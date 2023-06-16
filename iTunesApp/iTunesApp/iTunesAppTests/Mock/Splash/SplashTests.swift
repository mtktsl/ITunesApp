//
//  SplashTests.swift
//  iTunesAppTests
//
//  Created by Metin Tarık Kiki on 16.06.2023.
//

import XCTest
@testable import iTunesApp

final class SplashTests: XCTestCase {
    
    var view: MockSplashViewController!
    var interactor: MockSplashInteractor!
    var router: MockSplashRouter!
    var presenter: MockSplashPresenter!
    
    override func setUp() {
        super.setUp()
        
        view = .init()
        interactor = .init()
        router = .init()
        presenter = .init(
            view: view,
            interactor: interactor,
            router: router
        )
        
        view.presenter = presenter
        router.viewController = view
        interactor.output = presenter
        
    }
    
    override func tearDown() {
        super.tearDown()
        
        view = nil
        interactor = nil
        presenter = nil
        router = nil
    }
    
    func test_viewDidLoad_InvokesRequiredViewMethods() {
        
        XCTAssertFalse(interactor.checkInternetInvoke)
        XCTAssertFalse(presenter.didAppearInvoke)
        XCTAssertFalse(router.navigateInvoke)
        XCTAssertFalse(view.didAppearInvoke)
        
        view.didAppear()
        
        XCTAssertTrue(view.didAppearInvoke)
        XCTAssertEqual(view.didAppearCount, 1)
        
        XCTAssertTrue(presenter.didAppearInvoke)
        XCTAssertEqual(presenter.didAppearCount, 1)
        
        XCTAssertTrue(interactor.checkInternetInvoke)
        XCTAssertEqual(interactor.checkInternetCount, 1)
        
        XCTAssertTrue(presenter.internetResultInvoke)
        XCTAssertEqual(presenter.internetResultCount, 1)
    }
}
