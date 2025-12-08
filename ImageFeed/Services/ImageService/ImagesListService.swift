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
    private init() {}
    
    private var lastLoadedPage: Int?
    private(set) var photos: [Photo] = []
    private let storage = OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    private var isLoading = false
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
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
    
    func fetchPhotosNextPage() {
        
        guard !isLoading else {
            imagesListLogger.debug("Попытка загрузки, но загрузка уже идёт")
            return
        }
        isLoading = true
        
        if let task = self.task {
            imagesListLogger.debug("Отмена предыдушего запроса на картинки.")
            task.cancel()
            self.task = nil
        }
        
        guard let token = storage.token else {
            imagesListLogger.debug("Отсутвует токен авторизации")
            return
        }
        
        // Здесь получим страницу номер 1, если ещё не загружали ничего,
        // и следующую страницу (на единицу больше), если есть предыдущая загруженная страница
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let urlRequest = makeImageListRequest(page: nextPage, token: token) else {
            return
        }
        
        let imageListTask = URLSession.shared.objectTask(for: urlRequest) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let photos):
                DispatchQueue.main.async {
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
                }
            case .failure(let error):
                imagesListLogger.error("Ошибка загрузки фотографий: \(error.localizedDescription)")
            }
            
            self.task = nil
        }
        
        self.task = imageListTask
        imageListTask.resume()
    }
}
