//
//  PuzzleEditorAssembly.swift
//  Sudo
//
//  Created by Jam on 17.03.2026.
//

import UIKit

enum PuzzleEditorAssembly {
	static func build(source: PuzzleEditorStartSource = .new) -> UIViewController {
		let presenter: PuzzleEditorPresenter = PuzzleEditorPresenter()
		let interactor: PuzzleEditorBusinessLogic = PuzzleEditorInteractor(
			presenter: presenter,
			source: source
		)
		let viewController: PuzzleEditorViewController = PuzzleEditorViewController(
			interactor: interactor
		)

		presenter.view = viewController

		return viewController
	}
}
