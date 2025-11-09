//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Denis Bokov on 09.11.2025.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accesToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    private enum CodingKeys: String, CodingKey {
        case accesToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
