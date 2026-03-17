//
//  PuzzleEditorPresenter.swift
//  Sudo
//
//  Created by Jam on 17.03.2026.
//

import UIKit

final class PuzzleEditorPresenter: PuzzleEditorPresentationLogic {
	// MARK: - Constants
	private enum Const {
		static let titleText: String = "Custom Puzzle"
		static let validateTitle: String = "Validation"
		static let validateSuccess: String = "Puzzle is valid."
		static let validateTimeout: String = "Validation took too long. Puzzle is not suitable."
		static let saveTitle: String = "Saved"
		static let saveMessage: String = "Puzzle saved."
		static let shareTitle: String = "Puzzle Code"
		static let shareEmpty: String = "Puzzle code is unavailable."
		static let importTitle: String = "Import"
		static let importSuccess: String = "Puzzle imported."
		static let importFailure: String = "Invalid code."
	}

	weak var view: PuzzleEditorDisplayLogic?

	// MARK: - PresentationLogic
	func presentStart(_ response: Model.Start.Response) {
		let viewModel: Model.EditorViewModel = makeViewModel(from: response.state)
		view?.displayStart(.init(board: viewModel))
	}

	func presentBoardChanged(_ response: Model.BoardChanged.Response) {
		let viewModel: Model.EditorViewModel = makeViewModel(from: response.state)
		view?.displayBoardChanged(.init(board: viewModel))
	}

	func presentValidate(_ response: Model.Validate.Response) {
		let message: String
		switch response.result {
		case .valid:
			message = Const.validateSuccess
		case .invalid(let reason):
			message = reason
		case .timeout:
			message = Const.validateTimeout
		}

		view?.displayValidate(.init(title: Const.validateTitle, message: message))
	}

	func presentSave(_ response: Model.Save.Response) {
		guard response.isSaved else {
			return
		}

		view?.displaySave(.init(title: Const.saveTitle, message: Const.saveMessage))
	}

	func presentShare(_ response: Model.Share.Response) {
		let message: String = response.code.isEmpty ? Const.shareEmpty : response.code
		view?.displayShare(
			.init(title: Const.shareTitle, message: message, code: response.code)
		)
	}

	func presentImport(_ response: Model.Import.Response) {
		let message: String = response.isImported ? Const.importSuccess : Const.importFailure
		view?.displayImport(.init(title: Const.importTitle, message: message))
	}

	func presentPlay(_ response: Model.Play.Response) {
		let boardViewController: UIViewController = BoardAssembly.build(
			source: .customPuzzle(
				puzzle: response.puzzle,
				solution: response.solution
			)
		)

		if let navigationController: UINavigationController = (view as? UIViewController)?.navigationController {
			navigationController.pushViewController(boardViewController, animated: true)
		} else {
			(view as? UIViewController)?.present(boardViewController, animated: true)
		}
	}

	// MARK: - Private methods
	private func makeViewModel(from state: Model.EditorState) -> Model.EditorViewModel {
		let cells: [Model.CellViewModel] = state.cells.enumerated().map { index, cell in
			Model.CellViewModel(
				valueText: cell.value.map(String.init) ?? "",
				isSelected: index == state.selectedIndex
			)
		}

		let hasSelection: Bool = state.selectedIndex != nil

		return Model.EditorViewModel(
			titleText: Const.titleText,
			statusText: state.statusText,
			cells: cells,
			hasSelection: hasSelection
		)
	}
}
