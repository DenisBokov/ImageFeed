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
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
}
