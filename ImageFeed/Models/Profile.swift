//
//  Profile.swift
//  ImageFeed
//
//  Created by Denis Bokov on 22.11.2025.
//


import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}
