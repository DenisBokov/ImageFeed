//
//  PhotoLike.swift
//  ImageFeed
//
//  Created by Denis Bokov on 10.12.2025.
//

import Foundation

struct ChangeLike: Codable {
    let photo: PhotoLike
}

struct PhotoLike: Codable {
    let id: String
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case isLiked = "liked_by_user"
    }
}
