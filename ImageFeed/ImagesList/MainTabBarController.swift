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
                
        guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: imageListViewIdentifier
        ) as? ImagesListViewController else {
            fatalError("Can't instantiate ImagesListViewController")
        }
        
        let imagesListViewPresenter = ImagesListViewPresenter()
        
        imagesListViewController.presenter = imagesListViewPresenter
        imagesListViewPresenter.view = imagesListViewController
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabEditorialActive),
            selectedImage: nil
        )
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfileViewPresenter()
        
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
                
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
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
