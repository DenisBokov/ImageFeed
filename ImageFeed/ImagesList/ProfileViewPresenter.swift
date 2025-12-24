//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Denis Bokov on 23.12.2025.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didTapLogout()
}

final class ProfileViewPresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private var profileImageObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        observeAvatarChanges()
        updateProfile()
        updateAvatar()
    }
    
    func didTapLogout() {
        view?.showLogoutAlert()
    }
    
    private func updateProfile() {
        if let profile = profileService.profile {
            view?.setProfile(
                name: profile.name.isEmpty ? "Имя не указано" : profile.name,
                nickname: profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName,
                description: (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : (profile.bio ?? "")
            )
        }
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else {
            return
        }
        
        view?.setAvatar(with: imageUrl)
    }
    
    private func observeAvatarChanges() {
        profileImageObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
                self.updateProfile()
            }
    }
}
