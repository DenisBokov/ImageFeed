//
//  ProfileViewTests.swift
//  ImageFeed
//
//  Created by Denis Bokov on 24.12.2025.
//

@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter as? any ProfilePresenterProtocol
        presenter.view = viewController as? ProfileViewControllerProtocol
        
        //when
         _ = viewController.view
         
         //then
         XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }
    
    func testViewControllerCallsDidTapLogout() {
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        _ = viewController.view
        
        // симулируем нажатие на кнопку logout
        presenter.didTapLogout()
        
        XCTAssertTrue(presenter.didTapLogoutCalled)
    }
}

final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var didTapLogoutCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true
    }
}

