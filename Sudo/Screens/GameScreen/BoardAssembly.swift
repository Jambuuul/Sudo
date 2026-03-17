//
//  Assembly.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//


import UIKit

enum BoardAssembly {
    static func build(source: BoardStartSource = .newGame(difficulty: .easy)) -> UIViewController {
		let presenter: BoardPresenter = BoardPresenter()
		let interactor: BoardBusinessLogic = BoardInteractor(
			presenter: presenter,
			source: source
		)
		let viewController: BoardViewController = BoardViewController(
            interactor: interactor
        )

        presenter.view = viewController

        return viewController
    }
}
