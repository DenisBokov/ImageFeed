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
    
    func showError(vc: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Что-то пошло не так. Попробовать ещё раз?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))

        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
            completion()
        })

        vc.present(alert, animated: true)
    }
    
    func showLogoutAlert(vc: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Да", style: .cancel) { _ in
            completion()
        })

        alert.addAction(UIAlertAction(title: "Нет", style: .default))

        vc.present(alert, animated: true)
    }
}
