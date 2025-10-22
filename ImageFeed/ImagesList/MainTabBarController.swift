//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Denis Bokov on 22.10.2025.
//

import UIKit

final class MainTabBarController: UITabBarController {
    private let imageListViewIdentifier = "imageListViewIdentifier"
    private let profileViewIdentifier = "profileViewIdentifier"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
                
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: imageListViewIdentifier
        )
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
                
        let profileViewController = storyboard.instantiateViewController(
            withIdentifier: profileViewIdentifier
        )
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypBlack
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = tabBar.standardAppearance
               
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
