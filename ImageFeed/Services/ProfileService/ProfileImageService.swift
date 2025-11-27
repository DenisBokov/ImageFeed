//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Denis Bokov on 26.11.2025.
//

import Foundation
import os

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.myapp",
    category: "ProfileImageService"
)

private enum NetworkError: Error {
    case codeError
    case invalidResponse
    case decodingError
    case invalidRequest
}


final class ProfileImageService {
    static let shared = ProfileImageService()
    private var task: URLSessionTask?
    private let storage = OAuth2TokenStorage.shared
    private(set) var avatarURL: String?
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
        
    
    private init() {}
    
    private func makeAvatarProfileRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/user/\(username)") else {
            logger.error("Не корректный URL аватарки!")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        
        if let task = self.task {
            logger.debug("Отмена предыдушего запроса на аватарку пользователя.")
            task.cancel()
            self.task = nil
        }
        
        guard let token = storage.token else {
            completion(.failure(NSError(
                domain: "ProfileImageService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"]
            )))
            return
        }
        
        guard let urlRequest = makeAvatarProfileRequest(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        logger.debug("Запрос аватарки для \(username)")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            
            if let error {
                logger.error("Ошибка сети: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let http = response as? HTTPURLResponse,
               !(200...299).contains(http.statusCode) {
                logger.error("HTTP status error: \(http.statusCode)")
                completion(.failure(NetworkError.codeError))
                return
            }
            
            guard let data else {
                logger.error("Пустой ответ от сервера.")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(UserResult.self, from: data)
                self?.avatarURL = result.profileImage.small
                completion(.success(result.profileImage.small))
                NotificationCenter.default                                     // 1
                    .post(                                                     // 2
                        name: ProfileImageService.didChangeNotification,       // 3
                        object: self,                                          // 4
                        userInfo: ["URL": result.profileImage.small])
            } catch {
                logger.error("Ошибка декодирования: \(error.localizedDescription)")
                completion(.failure(error))
            }
            
        }
        
        self.task = task
        task.resume()
    }
}

