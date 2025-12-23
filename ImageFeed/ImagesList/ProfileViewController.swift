//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Denis Bokov on 18.10.2025.
//

import UIKit
import Kingfisher


enum ImageFeedFont: String {
    case regular = "SFProDisplay-Regular"
    case bold = "SFProDisplay-Bold"
}

enum ImageFeedColor: String {
    case black = "YP Black"
    case gray = "YP Gray"
    case white = "YP White"
}

protocol ProfileViewControllerProtocol: AnyObject {
    func setProfile(name: String, nickname: String, description: String)
    func setAvatar(with url: URL?)
}

final class ProfileViewController: UIViewController {
    
    private let descriptionLabel = UILabel()
    private let nicknameLabel = UILabel()
    private let nameLabel = UILabel()
    private let logoutButton = UIButton()
    private let profileImage = UIImageView()
    
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let alertPresenter = AlertPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: ImageFeedColor.black.rawValue)
        setupProfileImage(for: profileImage)
        setupLabels()
        setupLogoutButton(for: logoutButton)
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(with: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
            }
        
        updateAvatar()
        
        logoutButton.addAction(UIAction { [weak self] _ in
            self?.logout()
        }, for: .touchUpInside)
    }
    
    private func setupProfileImage(for imageView: UIImageView) {
        imageView.image = UIImage.ImageApp.profile
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.widthAnchor.constraint(equalToConstant: 70),
        ])
    }
    
    private func setupLabels() {
        configureLabel(
            nameLabel,
            text: "Екатерина Новикова",
            fontName: ImageFeedFont.bold.rawValue,
            fontSize: 23,
            colorName: ImageFeedColor.white.rawValue
        )
        
        configureLabel(
            nicknameLabel,
            text: "@ekaterina_novikova",
            fontName: ImageFeedFont.regular.rawValue,
            fontSize: 13,
            colorName: ImageFeedColor.gray.rawValue
        )
        
        configureLabel(
            descriptionLabel,
            text: "Hello, World!",
            fontName: ImageFeedFont.regular.rawValue,
            fontSize: 13,
            colorName: ImageFeedColor.white.rawValue
        )
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nicknameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nicknameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupLogoutButton(for button: UIButton) {
        button.setImage(UIImage.ImageApp.logout, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureLabel(_ label: UILabel, text: String, fontName: String, fontSize: CGFloat, colorName: String) {
        label.text = text
        label.font = UIFont(name: fontName, size: fontSize)
        label.textColor = UIColor(named: colorName)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }

        print("imageUrl: \(imageUrl)")
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImage.kf.indicatorType = .activity
        profileImage.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh,
            ]) { result in
                
                switch result {
                   
                case .success(let value):
                
                    print(value.image)
                    
                    print(value.cacheType)
                
                    print(value.source)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
}

extension ProfileViewController {
    private func updateProfileDetails(with profile: Profile) {
        nameLabel.text = profile.name.isEmpty
            ? "Имя не указано"
            : profile.name
        nicknameLabel.text = profile.loginName.isEmpty
            ? "@неизвестный_пользователь"
            : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true)
            ? "Профиль не заполнен"
            : profile.bio
    }
}

extension ProfileViewController {
    private func logout() {
        alertPresenter.showLogoutAlert(vc: self) {
            ProfileLogoutService.shared.logout()
        }
    }
}


