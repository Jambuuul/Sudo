//
//  SavedGamesAssembly.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

import UIKit

enum SavedGamesAssembly {
	static func build() -> UIViewController {
		let presenter: SavedGamesPresenter = SavedGamesPresenter()
		let interactor: SavedGamesBusinessLogic = SavedGamesInteractor(presenter: presenter)
		let viewController: SavedGamesViewController = SavedGamesViewController(
			interactor: interactor
		)

		presenter.view = viewController

		return viewController
	}
}
