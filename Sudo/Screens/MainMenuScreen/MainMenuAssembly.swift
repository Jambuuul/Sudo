//
//  Assembly.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//


import UIKit

enum MainMenuAssembly {
    static func build() -> UIViewController {
        let presenter: MainMenuPresenter = MainMenuPresenter()
        let interactor: MainMenuBusinessLogic = MainMenuInteractor(presenter: presenter)
        let viewController: UIViewController = MainMenuViewController(
            interactor: interactor
        )

        presenter.view = viewController

        return viewController
    }
}
