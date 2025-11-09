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
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
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
        
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.codeError))
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
                100..<200 ~= response.statusCode || 300...500 ~= response.statusCode {
                completion(.failure(NetworkError.codeError))
                return
            }
            
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                
                self?.tokenStorage.token = tokenResponse.accesToken
                print("TOKEN SAVED", tokenResponse.accesToken)
                
                DispatchQueue.main.async {
                    completion(.success(tokenResponse.accesToken))
                }
            } catch {
                print("DECODING ERROR", error)
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingError))
                }
            }
        }.resume()
    }
}
