//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Denis Bokov on 09.11.2025.
//

import Foundation

final class OAuth2Service {
    private enum NetworkError: Error {
        case codeError
        case invalidResponse
        case decodingError
        case invalidRequest
    }
    
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private let urlSession: URLSession = .shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var components = URLComponents(string: "https://unsplash.com/oauth/token") else { return nil }
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let authTokenURL = components.url else { return nil }
        
        var request = URLRequest(url: authTokenURL)
        request.httpMethod = "POST"
        
        print("ЭТО РЕКВЕСТ", request)
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
//        if task != nil {
//            if lastCode != code {
//                task?.cancel()
//            } else {
//                completion(.failure(NetworkError.invalidRequest))
//            }
//        } else {
//            if lastCode == code {
//                completion(.failure(NetworkError.invalidRequest))
//                return
//            }
//        }
        
        guard lastCode != code else {                               
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task?.cancel()
        
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.codeError))
            return
        }
        
        let dataTask = urlSession.dataTask(with: request) { [weak self] data, response, error in
            
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let response = response as? HTTPURLResponse,
                   !(200...299).contains(response.statusCode) {
                    completion(.failure(NetworkError.codeError))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.invalidResponse))
                    return
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("JSON STRING: \(jsonString)")
                }
                
                do {
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self?.tokenStorage.token = tokenResponse.accessToken
                    print("TOKEN SAVED", tokenResponse.accessToken)
                    completion(.success(tokenResponse.accessToken))
                } catch {
                    print("DECODING ERROR", error)
                    completion(.failure(NetworkError.decodingError))
                }
                
                self?.task = nil
                self?.lastCode = nil
            }
            
        }
        self.task = dataTask
        dataTask.resume()
    }
}
