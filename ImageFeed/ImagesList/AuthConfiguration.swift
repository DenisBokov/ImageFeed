//
//  Constants.swift
//  ImageFeed
//
//  Created by Denis Bokov on 30.10.2025.
//

import Foundation

enum Constants {
    static let accessKey: String = "TeZ6UNd6UYN1_6l-MtZYQA-pBDfelQfhkp5Y1lgiYSo"
    static let secretKey: String = "Alak2vKzIE_NbSgLctNwq9fzdffIJM4o6a5c_VSbhhU"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope: String = "public+read_user+write_likes"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Couldn't create URL")
        }
        return url
    }()
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.defaultBaseURL)
    }
}
