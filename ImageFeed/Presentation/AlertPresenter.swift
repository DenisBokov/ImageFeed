//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Denis Bokov on 01.12.2025.
//

import UIKit

final class AlertPresenter {
    func showAlertError(vc: UIViewController) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Ок", style: .default))

        vc.present(alert, animated: true)
    }
}
