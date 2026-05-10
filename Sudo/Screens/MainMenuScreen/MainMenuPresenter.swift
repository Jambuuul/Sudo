//
//  Presenter.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//

import UIKit

final class MainMenuPresenter: MainMenuPresentationLogic {

	
    // MARK: - Constants
    private enum Const {
		static let networkLoadingTitle: String = "Loading Puzzle"
		static let networkLoadingMessage: String = "Please wait."
		static let networkErrorTitle: String = "Network Error"
		static let networkErrorMessage: String = "Unable to load puzzle from network."
		static let okTitle: String = "OK"
    }

    weak var view: UIViewController?

    // MARK: - PresentationLogic
    func presentStart(_ response: Model.Start.Response) {
        
    }
	
	func presentNewGame(_ response: Model.NewGame.Response) {
		let source: BoardStartSource
		if let puzzle: [[Int]] = response.puzzle,
		   let solution: [[Int]] = response.solution,
		   let cages: [KillerCage] = response.cages {
			source = .killerPuzzle(
				difficulty: response.difficulty,
				puzzle: puzzle,
				solution: solution,
				cages: cages
			)
		} else if let puzzle: [[Int]] = response.puzzle,
				  let solution: [[Int]] = response.solution {
			source = .networkPuzzle(
				difficulty: response.difficulty,
				puzzle: puzzle,
				solution: solution
			)
		} else {
			source = .newGame(difficulty: response.difficulty)
		}

        let boardViewController: UIViewController = BoardAssembly.build(source: source)
		performAfterClosingPresented { [weak self] in
			if let navigationController: UINavigationController = self?.view?.navigationController {
				navigationController.pushViewController(boardViewController, animated: true)
			} else {
				self?.view?.present(boardViewController, animated: true)
			}
		}
	}

	func presentNetworkLoading(_ response: Model.NetworkLoading.Response) {
		performAfterClosingPresented { [weak self] in
			let alert: UIAlertController = UIAlertController(
				title: Const.networkLoadingTitle,
				message: Const.networkLoadingMessage,
				preferredStyle: .alert
			)
			self?.view?.present(alert, animated: true)
		}
	}

	func presentNetworkFailure(_ response: Model.NetworkFailure.Response) {
		performAfterClosingPresented { [weak self] in
			let alert: UIAlertController = UIAlertController(
				title: Const.networkErrorTitle,
				message: Const.networkErrorMessage,
				preferredStyle: .alert
			)
			alert.addAction(UIAlertAction(title: Const.okTitle, style: .default))
			self?.view?.present(alert, animated: true)
		}
	}

	// MARK: - Private methods
	private func performAfterClosingPresented(_ completion: @escaping () -> Void) {
		guard let presented: UIViewController = view?.presentedViewController else {
			completion()
			return
		}

		presented.dismiss(animated: true) {
			completion()
		}
	}
}
