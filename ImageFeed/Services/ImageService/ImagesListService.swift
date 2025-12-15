//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Denis Bokov on 08.12.2025.
//

import Foundation
import os

private let imagesListLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.myapp",
    category: "ImageListService"
)

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var lastLoadedPage: Int?
    private(set) var photos: [Photo] = []
    private let storage = OAuth2TokenStorage.shared
    private var photoTask: URLSessionTask?
    private var likeTask: URLSessionTask?
    private var isLoading = false
    
    private init() {}
    
    /// Запрос на получение фотографий
    func fetchPhotosNextPage() {
        
        guard !isLoading else {
            imagesListLogger.debug("Попытка загрузки, но загрузка уже идёт")
            return
        }
        isLoading = true
        
        if let task = self.photoTask {
            imagesListLogger.debug("Отмена предыдушего запроса на картинки.")
            task.cancel()
            self.photoTask = nil
        }
        
        guard let token = storage.token else {
            imagesListLogger.debug("Отсутвует токен авторизации")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let urlRequest = makeImageListRequest(page: nextPage, token: token) else {
            return
        }
        
        imagesListLogger.debug("Запрос фотографий на странице \(nextPage)")
        
        let imageListTask = URLSession.shared.objectTask(for: urlRequest) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            self.isLoading = false
            
            DispatchQueue.main.async {
                switch result {
                case .success(let photos):
                    for photo in photos {
                        self.photos.append(Photo(from: photo))
                    }
                    
                    imagesListLogger.info("Фото загружены успешно.")
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["Photo": self.photos]
                    )
                case .failure(let error):
                    imagesListLogger.error("Ошибка загрузки фотографий: \(error.localizedDescription)")
                }
                
                self.photoTask = nil
            }
        }
        
        self.photoTask = imageListTask
        imageListTask.resume()
    }
    
    /// Запрос на изменение лайков
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if let task = self.likeTask {
            imagesListLogger.debug("Отмена предыдушего запроса на лайки.")
            task.cancel()
            self.likeTask = nil
        }
        
        guard let token = storage.token else {
            imagesListLogger.debug("Отсутвует токен авторизации")
            return
        }
        
        guard let urlRequest = makeImageLikeRequest(photoId: photoId, isLike: isLike, token: token) else {
            imagesListLogger.error("Не удалось создать запрос на лайки.")
            return
        }
        
        imagesListLogger.debug("Запрос на изменение лайков")
        
        let likeTask = URLSession.shared.objectTask(for: urlRequest) { [weak self] (result: Result<ChangeLike, Error>) in
            guard let self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    
                    if let index = self.photos.firstIndex(where: { photo in
                        photo.id == result.photo.id
                    }) {
                        let photo = self.photos[index]
                        
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        
                        self.photos[index] = newPhoto
                        
                        imagesListLogger.info("Лайк успешно изменён.")
                        
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["Photo": self.photos]
                        )
                    }
                    
                    completion(.success(()))
                    
                case .failure(let error):
                    imagesListLogger.error("Ошибка изменения лайка: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                
                self.likeTask = nil
            }
        }
        
        self.likeTask = likeTask
        likeTask.resume()
    }
    
    private func makeImageListRequest(page: Int, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(page)&per_page=10") else {
            imagesListLogger.error("Не корректный URL для запроса картинок!")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeImageLikeRequest(photoId: String, isLike: Bool, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            imagesListLogger.error("Не корректный URL для запроса лайков!")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension ImagesListService {
    func cleanImagesList() {
        imagesListLogger.debug("Очистка списка загруженных фотографий.")
        photos.removeAll()
        lastLoadedPage = nil
        photoTask?.cancel()
        photoTask = nil
        likeTask?.cancel()
        likeTask = nil
    }
}
