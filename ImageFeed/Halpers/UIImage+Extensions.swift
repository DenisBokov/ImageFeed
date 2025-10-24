//
//  UIColor+Extensions.swift
//  ImageFeed
//
//  Created by Denis Bokov on 24.10.2025.
//

import UIKit

extension UIImage {
    enum ImageApp {
        static func image(named: String) -> UIImage? {
            guard let image = UIImage(named: named) else {
                assertionFailure("Image with name \(named) not found")
                return UIImage()
            }
            return image
        }
        
        static let profile = image(named: "ProfileImage")
        static let logout =  image(named: "LoguotImage")
        static let backward = image(named: "BackwardButton")
        static let save = image(named: "SaveButton")
    }
}
