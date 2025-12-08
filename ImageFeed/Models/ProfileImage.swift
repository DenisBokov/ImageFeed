//
//  ProfileImage.swift
//  ImageFeed
//
//  Created by Denis Bokov on 02.12.2025.
//

import Foundation

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
    
    private enum CodingKeys: String, CodingKey {
         case small, medium, large
     }
}

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
