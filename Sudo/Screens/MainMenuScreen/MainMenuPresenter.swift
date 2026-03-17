//
//  Presenter.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//

import UIKit

final class MainMenuPresenter: MainMenuPresentationLogic {

	
    // MARK: - Constants
    private enum Constants {

    }

    weak var view: UIViewController?

    // MARK: - PresentationLogic
    func presentStart(_ response: Model.Start.Response) {
        
    }
	
	func presentNewGame(_ response: Model.NewGame.Response) {
        let boardViewController: UIViewController = BoardAssembly.build(
			source: .newGame(difficulty: response.difficulty)
		)

        if let navigationController: UINavigationController = view?.navigationController {
            navigationController.pushViewController(boardViewController, animated: true)
        } else {
            view?.present(boardViewController, animated: true)
        }
	}
}
