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
    
    weak var delegate: WebViewViewControllerDelegate?
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAuthView()
        webView.navigationDelegate = self
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

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
          if let code = code(from: navigationAction) { //1
              delegate?.webViewViewController(self, didAuthenticateWithCode: code)                    //2
              decisionHandler(.cancel)                 //3
          } else {
              decisionHandler(.allow)                  //4
          }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,                         //1
            let urlComponents = URLComponents(string: url.absoluteString),  //2
            urlComponents.path == "/oauth/authorize/native",                //3
            let items = urlComponents.queryItems,                           //4
            let codeItem = items.first(where: { $0.name == "code" })        //5
        {
            return codeItem.value                                           //6
        } else {
            return nil
        }
    }
}
