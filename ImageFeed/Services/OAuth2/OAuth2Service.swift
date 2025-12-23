//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Denis Bokov on 09.11.2025.
//

import Foundation
import os

private let authLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.myapp",
    category: "OAuth2Service"
)

final class OAuth2Service {
    private enum NetworkError: Error {
        case codeError
        case invalidResponse
        case decodingError
        case invalidRequest
    }
    
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession: URLSession = .shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            authLogger.error("Повторный запрос с тем же кодом авторизации")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            authLogger.error("Не создан запрос на получение токена")
            completion(.failure(NetworkError.codeError))
            return
        }
        
        authLogger.debug("Отправка запроса")
        
        let dataTask = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let tokenResponse):
                    authLogger.info("OAUTH: Токен получен")
                    self?.tokenStorage.token = tokenResponse.accessToken
                    completion(.success(tokenResponse.accessToken))
                case .failure(let error):
                    authLogger.error("Ошибка получения токена: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                
                self?.task = nil
                self?.lastCode = nil
            }
        }
        self.task = dataTask
        dataTask.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var components = URLComponents(string: "https://unsplash.com/oauth/token") else {
            authLogger.error("Ошибка создания URL")
            return nil
        }
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let authTokenURL = components.url else {
            authLogger.error("Ошибка формирования URL для запроса токена")
            return nil
        }
        
        var request = URLRequest(url: authTokenURL)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}
