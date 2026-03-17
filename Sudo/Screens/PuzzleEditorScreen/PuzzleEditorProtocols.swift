//
//  PuzzleEditorProtocols.swift
//  Sudo
//
//  Created by Jam on 17.03.2026.
//

protocol PuzzleEditorBusinessLogic {
	typealias Model = PuzzleEditorModel
	func loadStart(_ request: Model.Start.Request)
	func selectCell(_ request: Model.SelectCell.Request)
	func inputDigit(_ request: Model.InputDigit.Request)
	func clearCell(_ request: Model.ClearCell.Request)
	func validatePuzzle(_ request: Model.Validate.Request)
	func savePuzzle(_ request: Model.Save.Request)
	func playPuzzle(_ request: Model.Play.Request)
	func sharePuzzle(_ request: Model.Share.Request)
	func importPuzzle(_ request: Model.Import.Request)
}

protocol PuzzleEditorPresentationLogic {
	typealias Model = PuzzleEditorModel
	func presentStart(_ response: Model.Start.Response)
	func presentBoardChanged(_ response: Model.BoardChanged.Response)
	func presentValidate(_ response: Model.Validate.Response)
	func presentSave(_ response: Model.Save.Response)
	func presentShare(_ response: Model.Share.Response)
	func presentImport(_ response: Model.Import.Response)
	func presentPlay(_ response: Model.Play.Response)
}

protocol PuzzleEditorDisplayLogic: AnyObject {
	typealias Model = PuzzleEditorModel
	func displayStart(_ viewModel: Model.Start.ViewModel)
	func displayBoardChanged(_ viewModel: Model.BoardChanged.ViewModel)
	func displayValidate(_ viewModel: Model.Validate.ViewModel)
	func displaySave(_ viewModel: Model.Save.ViewModel)
	func displayShare(_ viewModel: Model.Share.ViewModel)
	func displayImport(_ viewModel: Model.Import.ViewModel)
}
