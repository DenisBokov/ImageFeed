//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Denis Bokov on 26.11.2025.
//

import Foundation
import os

private let profileImageLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.myapp",
    category: "ProfileImageService"
)

final class ProfileImageService {
    static let shared = ProfileImageService()
    private var task: URLSessionTask?
    private let storage = OAuth2TokenStorage.shared
    private(set) var avatarURL: String?
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
        
    
    private init() {}
    
    private func makeAvatarProfileRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            profileImageLogger.error("Не корректный URL для запроса аватарки!")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        
        if let task = self.task {
            profileImageLogger.debug("Отмена предыдушего запроса на аватарку пользователя.")
            task.cancel()
            self.task = nil
        }
        
        guard let token = storage.token else {
            completion(.failure(NSError(
                domain: "ProfileImageService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Отсутвует токен авторизации"]
            )))
            return
        }
        
        guard let urlRequest = makeAvatarProfileRequest(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        profileImageLogger.debug("Запрос аватарки для \(username)")
        
        let profileImageTask = URLSession.shared.objectTask(for: urlRequest) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let user):
                guard let self else { return }
                let avatarURL = user.profileImage.small
                profileImageLogger.info("Аватарка успешно получена")
                self.avatarURL = avatarURL
                completion(.success(avatarURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": self.avatarURL ?? ""]
                )
                
            case .failure(let error):
                profileImageLogger.error("Ошибка получения аватарки: \(error.localizedDescription)")
                completion(.failure(error))
            }
            
            self?.task = nil
        }
        self.task = profileImageTask
        profileImageTask.resume()
    }
}

