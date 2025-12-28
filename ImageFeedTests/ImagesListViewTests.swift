//
//  ImagesListViewTests.swift
//  ImageFeed
//
//  Created by Denis Bokov on 28.12.2025.
//

@testable import ImageFeed
import XCTest

final class ImagesListViewTests: XCTestCase {
    func testViewDidLoadCallsPresenterViewDidLoad() {
        let imagesVC = ImagesListViewController()
        let presenterSpy = ImagesListViewPresenterSpy()
        
        imagesVC.configure(presenter: presenterSpy)
        imagesVC.loadViewIfNeeded()
        
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testTableViewNumberOfRows() {
        let imagesVC = ImagesListViewController()
        let presenterSpy = ImagesListViewPresenterSpy()
        
        imagesVC.configure(presenter: presenterSpy)
        
        imagesVC.loadViewIfNeeded()
        imagesVC.tableView = UITableView()
        imagesVC.tableView.dataSource = imagesVC
        imagesVC.tableView.delegate = imagesVC
        
        let rows = imagesVC.tableView.dataSource?.tableView(imagesVC.tableView, numberOfRowsInSection: 0)
        
        XCTAssertEqual(rows, 1)
        XCTAssertTrue(presenterSpy.getNumberOfPhotosCalled)
    }
    
    func testLoadNextPageIfNeeded_callsService() {
        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenterSpy()
        presenter.view = viewSpy
        presenter.photos = [
            Photo(
                id: "1",
                size: CGSize(width: 100, height: 100),
                createdAt: Date(),
                welcomeDescription: "Test",
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            )
        ]
        
        presenter.loadNextPageIfNeeded(for: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(presenter.isFetchNextPageCalled)
    }
    
    func testShowLoading_HideLoading_UpdatePhoto_ShowError() {
        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenterSpy()
        presenter.view = viewSpy
        
        viewSpy.showLoading()
        viewSpy.hideLoading()
        viewSpy.updatePhoto(at: 0, isLiked: true)
        viewSpy.showError()
        
        XCTAssertTrue(viewSpy.showLoadingCalled)
        XCTAssertTrue(viewSpy.hideLoadingCalled)
        XCTAssertEqual(viewSpy.updatedIndex, 0)
        XCTAssertTrue(viewSpy.showErrorCalled)
    }
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: (any ImageFeed.ImagesListPresenterProtocol)?
    
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var updatedIndex: Int?
    var showErrorCalled = false
    var isReloadTableView = false
    
    func updateTableViewWithDeletedRows(at indexPaths: [IndexPath]) {
        isReloadTableView = true
    }
    
    func updateTableViewWithInsertedRows(at indexPaths: [IndexPath]) {
        isReloadTableView = true
    }
    
    func showLoading() {
        showLoadingCalled = true
    }
    
    func hideLoading() {
        hideLoadingCalled = true
    }
    
    func updatePhoto(at index: Int, isLiked: Bool) {
        updatedIndex = index
    }
    
    func showError() {
        showErrorCalled = true
    }
}

final class ImagesListViewPresenterSpy: ImagesListPresenterProtocol {
    var view: ImageFeed.ImagesListViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var configureCellDataCalledAt: IndexPath?
    var getNumberOfPhotosCalled = false
    var getPhotoCalledAt: IndexPath?
    var isFetchNextPageCalled = false
    
    var photos: [Photo] = [
        Photo(id: "1",
              size: CGSize(width: 100, height: 100),
              createdAt: Date(),
              welcomeDescription: "Test",
              thumbImageURL: "",
              largeImageURL: "",
              isLiked: false)
    ]
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateTableViewAnimated() {
        
    }
    
    func configureCellData(at indexPath: IndexPath) -> ImageFeed.CellData {
        configureCellDataCalledAt = indexPath
        return CellData(imageUrl: nil, dateString: "Test", isLiked: false)
    }
    
    func getNumberOfPhotos() -> Int {
        getNumberOfPhotosCalled = true
        return 1
    }
    
    func getPhoto(at indexPath: IndexPath) -> ImageFeed.Photo {
        getPhotoCalledAt = indexPath
        return Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: "",
            largeImageURL: "",
            isLiked: false
        )
    }
    
    func loadNextPageIfNeeded(for indexPath: IndexPath) {
        isFetchNextPageCalled = true
    }
    
    func didTapLike(at index: Int) {
    
    }
}
