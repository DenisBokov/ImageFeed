//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Denis Bokov on 10.11.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let tokenKey = "oauthToken"
    private let storage = KeychainWrapper.standard
    
    var token: String? {
        get {
            storage.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                storage.set(newValue, forKey: tokenKey)
            } else {
                storage.removeObject(forKey: tokenKey)
            }
        }
    }
}
