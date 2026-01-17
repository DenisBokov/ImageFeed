//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Denis Bokov on 28.12.2025.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        // тестируем сценарий авторизации
        
        /*
         У приложения мы получаем список кнопок на экране и получаем нужную кнопку по тексту на ней
         Далее вызываем функцию tap() для нажатия на этот элемент
         */
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["SplashViewController"]
        
        // Подождать, пока экран авторизации открывается и загружается
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("")
        webView.swipeUp()
        
        // Нажать кнопку логина
        webView.buttons["Login"].tap()
        
        // Подождать, пока открывается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
    }
    
    func testFeed() throws {
        // тестируем сценарий ленты
        
        // Подождать, пока открывается и загружается экран ленты
        let tablesQuery = app.tables
        
        // Сделать жест «смахивания» вверх по экрану для его скролла
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        // Поставить лайк в ячейке верхней картинки
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["LikeButtonOff"].tap()
        
        // Отменить лайк в ячейке верхней картинки
        cellToLike.buttons["LikeButtonOn"].tap()
        
        sleep(2)
        
        // Нажать на верхнюю ячейку
        cellToLike.tap()
        
        // Подождать, пока картинка открывается на весь экран
        sleep(2)
        
        // Увеличить картинку
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        
        // Вернуться на экран ленты
        let navBackButtonWhiteButton = app.buttons["BackwardButton"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        // тестируем сценарий профиля
        
        // Подождать, пока открывается и загружается экран ленты
        sleep(3)
        
        // Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        // Проверить, что на нём отображаются ваши персональные данные
        XCTAssertTrue(app.staticTexts["Denis Bokov"].exists)
        XCTAssertTrue(app.staticTexts["@mrcorrect"].exists)
        
        // Нажать кнопку логаута
        app.buttons["LoguotImage"].tap()
        
        // Проверить, что открылся экран авторизации
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
