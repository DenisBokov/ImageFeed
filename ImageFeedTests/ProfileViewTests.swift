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
        
        viewController.loadViewIfNeeded()
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsShowLogoutAlert() {
        let viewSpy = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        presenter.view = viewSpy
        
        presenter.didTapLogout()
        
        XCTAssertTrue(viewSpy.showLogoutAlertCalled)
    }
    
    func testProfileViewControllerUpdateAvatarCalled() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.view?.setAvatar(with: Constants.defaultBaseURL)
        
        XCTAssertTrue(viewController.updateAvatarCalled)
    }
    
    func testProfileViewControllerUpdateProfile() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.view?.setProfile(name: "Test Name", nickname: "Test Nickname", description: "Test Description")
        
        XCTAssertTrue(viewController.isUpdateProfile)
    }
    
    func testProfileViewControllerSetDataProfile() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        let testName = "Test Name"
        let testNickname = "Test Nickname"
        let testDescription = "Test Description"
        presenter.view?.setProfile(name: testName, nickname: testNickname, description: testDescription)
        
        XCTAssertEqual(viewController.name, testName)
        XCTAssertEqual(viewController.nickname, testNickname)
        XCTAssertEqual(viewController.description, testDescription)
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
    var isUpdateProfile = false
    
    var name: String?
    var nickname: String?
    var description: String?
    
    func setProfile(name: String, nickname: String, description: String) {
        isUpdateProfile = true
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
