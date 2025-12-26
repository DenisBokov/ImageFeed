//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by Denis Bokov on 25.12.2025.
//

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    
    func updateTableViewAnimated()
    func configureCellData(at indexPath: IndexPath) -> CellData
    func getNumberOfPhotos() -> Int
    func getIndexOfPhoto(for indexPath: IndexPath) -> Photo
    func loadNextPageIfNeeded(for indexPath: IndexPath)
}

struct CellData {
    let imageUrl: URL?
    let dateString: String
    let isLiked: Bool // Только состояние лайка, без UI-логики
}

final class ImagesListViewPresenter: ImagesListPresenterProtocol {
    
    var view: ImagesListViewControllerProtocol?
    
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var alertPresenter: AlertPresenter = AlertPresenter()
    
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
         if newCount < oldCount {
             let indexPaths = (newCount..<oldCount).map { IndexPath(row: $0, section: 0) }
             view?.updateTableViewWithDeletedRows(at: indexPaths)
         }

         if newCount > oldCount {
             let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
             view?.updateTableViewWithInsertedRows(at: indexPaths)
         }
    }
    
    func subscribeToImagesListUpdates() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            })
    }
    
    func configureCellData(at indexPath: IndexPath) -> CellData {
        let photo = photos[indexPath.row]
        
        let imageUrl = URL(string: photo.thumbImageURL)
        let dateString = photo.createdAt != nil ? dateFormatter.string(from: photo.createdAt!) : ""
        let isLiked = photo.isLiked
        
        return CellData(imageUrl: imageUrl, dateString: dateString, isLiked: isLiked)
    }
    
    func getNumberOfPhotos() -> Int {
        photos.count
    }
    
    func getIndexOfPhoto(for indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }
    
    func loadNextPageIfNeeded(for indexPath: IndexPath) {
        // Если это последняя строка, загружаем следующую страницу
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

