//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Denis Bokov on 22.11.2025.
//

import Foundation
import os

private let profileLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.myapp",
    category: "ProfileService"
)

final class ProfileService {
    static let shared = ProfileService()
    
    private let urlSession: URLSession = .shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    private let profileURL = "https://api.unsplash.com/me"
    
    private init() {}
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: profileURL) else {
            profileLogger.error("Не корректный URL профеля!")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        if let task = self.task {
            profileLogger.debug("Отмена предыдущего запроса на получение профиля.")
            task.cancel()
            self.task = nil
        }
        
        guard let request = makeProfileRequest(token: token) else {
            profileLogger.error("Ошибка создания запроса на получение профиля")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        profileLogger.debug("Запуск запроса на получение профиля.")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profile):
                let name = [profile.firstName, profile.lastName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                let profile = Profile(
                    username: profile.username,
                    name: name,
                    loginName: "@\(profile.username)",
                    bio: profile.bio
                )
                
                profileLogger.info("Профиль получен")
                
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                profileLogger.error("Ошибка профиля: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }
}

extension ProfileService {
    func cleanProfile() {
        profileLogger.debug("Очистка данных профиля пользователя.")
        profile = nil
        task?.cancel()
        task = nil
    }
}
