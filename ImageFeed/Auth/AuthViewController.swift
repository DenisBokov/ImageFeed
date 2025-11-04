//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Denis Bokov on 02.11.2025.
//

import UIKit

final class AuthViewController: UIViewController  {
    
    private let identifierView: String = "ShowWebView"
    
    override func viewDidLoad() {
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == identifierView {
            guard
                let webViewVC = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(identifierView)")
                return
            }
            webViewVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "BackwardButton")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "BackwardButton")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black") // 4
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        //TODO: process code
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
