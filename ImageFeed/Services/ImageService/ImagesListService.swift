//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Denis Bokov on 08.12.2025.
//

import Foundation
import os

private let imageListLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.myapp",
    category: "ImageListService"
)

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    private var lastLoadedPage: Int?
    private(set) var photos: [Photo] = []
    private var task: URLSessionTask?
    private var isLoading = false
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private func makeImageListRequest(page: Int) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(page)") else {
            imageListLogger.error("Не корректный URL для запроса картинок!")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    func fetchPhotosNextPage() {
        
        guard !isLoading else {
            imageListLogger.debug("Попытка загрузки, но загрузка уже идёт")
            return
        }
        isLoading = true
        
        if let task = self.task {
            imageListLogger.debug("Отмена предыдушего запроса на картинки.")
            task.cancel()
            self.task = nil
        }
        
        // Здесь получим страницу номер 1, если ещё не загружали ничего,
        // и следующую страницу (на единицу больше), если есть предыдущая загруженная страница
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let urlRequest = makeImageListRequest(page: nextPage) else {
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
                    
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["Photo": self.photos]
                    )
                }
            case .failure(let error):
                imageListLogger.error("Ошибка загрузки фотографий: \(error.localizedDescription)")
            }
            
            self.task = nil
        }
        
        self.task = imageListTask
        imageListTask.resume()
    }
}
