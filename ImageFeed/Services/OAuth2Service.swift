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
    }
    
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
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
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.codeError))
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            func complete(_ result: Result<String, Error>) {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            if let error {
                complete(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
                100..<200 ~= response.statusCode || 300...500 ~= response.statusCode {
                complete(.failure(NetworkError.codeError))
                return
            }
            
            guard let data else {
                complete(.failure(NetworkError.invalidResponse))
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
                complete(.success(tokenResponse.accessToken))
            } catch {
                print("DECODING ERROR", error)
                complete(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
}
