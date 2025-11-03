//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Denis Bokov on 03.11.2025.
//


import Foundation
import UIKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ webViewViewController: WebViewViewController)
}
