//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Denis Bokov on 10.11.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage.shared
    private let profileService: ProfileService = .shared
    private let profileImageService: ProfileImageService = .shared
    
    private let logoImageView = UIImageView()
    private let authViewControllerIdentifier = "authViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: ImageFeedColor.black.rawValue)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupLogoImage(for: logoImageView)
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setupLogoImage(for imageView: UIImageView) {
        imageView.image = UIImage.ImageApp.logoOne
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: authViewControllerIdentifier) as? AuthViewController else {
            assertionFailure("Не удалось найти AuthViewController по идентификатору")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let window = windowScene.window else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            self?.switchToTabBarController()
        }
    }
}

private extension SplashViewController {
    func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                fetchProfileImage(profileName: profile.username)
            case .failure(let error):
                print("Failed to fetch profile: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchProfileImage(profileName: String) {
        profileImageService.fetchProfileImageURL(username: profileName) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let url):
                print("Avatar URL: \(url)")
                self.switchToTabBarController()
            case .failure(let error):
                print("Failed to fetch profile: \(error.localizedDescription)")
                self.switchToTabBarController()
            }
        }
    }
}
