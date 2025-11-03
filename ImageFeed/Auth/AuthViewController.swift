//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Denis Bokov on 02.11.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private let indicatorView: String = "ShowWebView"
    
    override func viewDidLoad() {
        configureBackButton()
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "BackwardButton") // 1
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "BackwardButton") // 2
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 3
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black") // 4
    }
}
