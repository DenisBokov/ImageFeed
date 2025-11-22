//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Denis Bokov on 22.11.2025.
//

import Foundation
import os

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp",
    category: "ProfileService"
)

private enum NetworkError: Error {
    case codeError
    case invalidResponse
    case decodingError
    case invalidRequest
}

final class ProfileService {
    static let shared = ProfileService()
    private let urlSession: URLSession = .shared
    private var task: URLSessionTask?
    private let profileURL = "https://api.unsplash.com/me"
    
    private init() {}
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: profileURL) else {
            logger.error("Не корректный URL профеля!")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        if let task = self.task {
            logger.debug("Cancelling previous profile request.")
            task.cancel()
            self.task = nil
        }
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        logger.debug("Starting profile request.")

        let task = urlSession.data(for: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
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
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    logger.debug("Profile JSON: \(jsonString)")
                }
                
                do {
                    let result = try JSONDecoder().decode(ProfileResult.self, from: data)
                    
                    let name = [result.firstName, result.lastName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    
                    let profile = Profile(
                        username: result.username,
                        name: name,
                        loginName: "@\(result.username)",
                        bio: result.bio
                    )
                    
                    logger.info("Profile successfully decoded.")
                    
                    completion(.success(profile))
                    
                } catch {
                    logger.error("Decoding error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                
                self?.task = nil
            }
        }

        self.task = task
        task.resume()
    }
}
