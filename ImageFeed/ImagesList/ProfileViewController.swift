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
        setupLabels(for: nameLabel, forAnd: nicknameLabel, and: descriptionLabel)
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
    
    private func setupLabels(for labelOne: UILabel, forAnd labelTwo: UILabel, and labelThree: UILabel) {
        labelOne.text = "Екатерина Новикова"
        labelOne.font = UIFont(name: "SFProDisplay-Bold", size: 23)
        labelOne.textColor = UIColor(named: "YP White")
        labelOne.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelOne)
        
        labelTwo.text = "@ekaterina_novikova"
        labelTwo.font = UIFont(name: "SFProDisplay-Regular", size: 13)
        labelTwo.textColor = UIColor(named: "YP Gray")
        labelTwo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelTwo)
        
        labelThree.text = "Hello, World!"
        labelThree.font = UIFont(name: "SFProDisplay-Regular", size: 13)
        labelThree.textColor = UIColor(named: "YP White")
        labelThree.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelThree)
        
        NSLayoutConstraint.activate([
            labelOne.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            labelOne.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            labelTwo.topAnchor.constraint(equalTo: labelOne.bottomAnchor, constant: 8),
            labelTwo.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            labelThree.topAnchor.constraint(equalTo: labelTwo.bottomAnchor, constant: 8),
            labelThree.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
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
}

