//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Denis Bokov on 22.11.2025.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            return nil
        }
        
        return windowScene.window
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }

}
