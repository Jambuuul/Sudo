//
//  SavedGamesPresenter.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

import UIKit

final class SavedGamesPresenter: SavedGamesPresentationLogic {
	weak var view: UIViewController?

	// MARK: - PresentationLogic
	func presentOpenGame(_ response: Model.OpenGame.Response) {
		let boardViewController: UIViewController = BoardAssembly.build(
			source: .savedGame(response.game)
		)

		if let navigationController: UINavigationController = view?.navigationController {
			navigationController.pushViewController(boardViewController, animated: true)
		} else {
			view?.present(boardViewController, animated: true)
		}
	}
}
