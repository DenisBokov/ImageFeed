//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Denis Bokov on 02.11.2025.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    
    @IBOutlet private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAuthView()
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else { // 1
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),          //2
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),     //3
            URLQueryItem(name: "response_type", value: "code"),                   //4
            URLQueryItem(name: "scope", value: Constants.accessScope)             //5
        ]
        
        guard let url = urlComponents.url else {                                 //6
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
