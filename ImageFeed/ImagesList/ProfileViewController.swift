//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Denis Bokov on 18.10.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private let descriptionLabel = UILabel()
    private let nicknameLabel = UILabel()
    private let nameLabel = UILabel()
    private let logoutButton = UIButton()
    private let profileImage = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfileImage(for: profileImage)
        setupLabels()
        setupLogoutButton(for: logoutButton)
    }
    
    private func setupProfileImage(for imageView: UIImageView) {
        imageView.image = UIImage(named: "ProfileImage")
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
            fontName: "SFProDisplay-Bold",
            fontSize: 23,
            colorName: "YP White"
        )
        
        configureLabel(
            nicknameLabel,
            text: "@ekaterina_novikova",
            fontName: "SFProDisplay-Regular",
            fontSize: 13,
            colorName: "YP White"
        )
        
        configureLabel(
            descriptionLabel,
            text: "Hello, World!",
            fontName: "SFProDisplay-Regular",
            fontSize: 13,
            colorName: "YP White"
        )
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nicknameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ])
    }
    
    private func setupLogoutButton(for button: UIButton) {
        button.setImage(UIImage.loguot, for: .normal)
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
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
    }
}

