//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Denis Bokov on 10.11.2025.
//

import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "oauthToken"
    private let userDefaults = UserDefaults.standard
    
    var token: String? {
        get {
            userDefaults.string(forKey: tokenKey)
        }
        set {
            userDefaults.set(newValue, forKey: tokenKey)
        }
    }
}
