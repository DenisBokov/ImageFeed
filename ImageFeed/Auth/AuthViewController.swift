//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Denis Bokov on 02.11.2025.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController  {
    
    private let identifierView: String = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    
    @IBOutlet var logButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logButton.titleLabel?.font = UIFont(name: ImageFeedFont.bold.rawValue, size: 17)
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
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let token):
                self.delegate?.didAuthenticate(self)
                print("ТОКЕН ПОЛУЧЕН: \(token)")
            case .failure(let error):
                print("ТОКЕН НЕ ПОЛУЧЕН: \(error)")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
