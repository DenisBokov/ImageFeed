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
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        
         _ = viewController.view

         XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsShowLogoutAlert() {
        let viewSpy = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        presenter.view = viewSpy

        presenter.didTapLogout()

        XCTAssertTrue(viewSpy.showLogoutAlertCalled)
    }
}

final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfilePresenterProtocol?
    
    var updateAvatarCalled = false
    var showLogoutAlertCalled = false
    
    var name: String?
    var nickname: String?
    var description: String?
    
    func setProfile(name: String, nickname: String, description: String) {
        self.name = name
        self.nickname = nickname
        self.description = description
    }
    
    func setAvatar(with url: URL?) {
        updateAvatarCalled = true
    }
    
    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
}
