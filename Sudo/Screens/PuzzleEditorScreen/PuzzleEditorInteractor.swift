//
//  PuzzleEditorInteractor.swift
//  Sudo
//
//  Created by Jam on 17.03.2026.
//

import Foundation

final class PuzzleEditorInteractor: PuzzleEditorBusinessLogic {
	// MARK: - Constants
	private enum Const {
		static let sideLength: Int = SudokuBoard.sideLength
		static let cellCount: Int = SudokuBoard.sideLength * SudokuBoard.sideLength
		static let defaultStatus: String = "Fill the grid or import a code."
		static let validationTimeoutSeconds: TimeInterval = 5
		static let invalidSizeMessage: String = "Puzzle size is invalid."
		static let invalidValueMessage: String = "Puzzle has invalid values."
		static let duplicateMessage: String = "Puzzle has duplicates."
		static let noUniqueMessage: String = "Puzzle must have a unique solution."
		static let noSolutionMessage: String = "Puzzle has no solution."
	}

	// MARK: - Fields
	private let presenter: PuzzleEditorPresentationLogic
	private let puzzleId: UUID
	private let createdAt: Date
	private var selectedIndex: Int?
	private var cells: [Int?]
	private var statusText: String
	private var validationToken: UUID?

	// MARK: - Lifecycle
	init(
		presenter: PuzzleEditorPresentationLogic,
		source: PuzzleEditorStartSource
	) {
		self.presenter = presenter
		switch source {
		case .new:
			self.puzzleId = UUID()
			self.createdAt = Date()
			self.cells = Array(repeating: nil, count: Const.cellCount)
			self.statusText = Const.defaultStatus
		case .existing(let puzzle):
			self.puzzleId = puzzle.id
			self.createdAt = puzzle.createdAt
			self.cells = PuzzleEditorInteractor.flatten(puzzle.puzzle)
			self.statusText = Const.defaultStatus
		}
	}

	// MARK: - BusinessLogic
	func loadStart(_ request: Model.Start.Request) {
		presenter.presentStart(.init(state: makeState()))
	}

	func selectCell(_ request: Model.SelectCell.Request) {
		guard (0..<Const.cellCount).contains(request.index) else {
			return
		}

		selectedIndex = request.index
		presenter.presentBoardChanged(.init(state: makeState()))
	}

	func inputDigit(_ request: Model.InputDigit.Request) {
		guard let selectedIndex else {
			return
		}

		guard SudokuBoard.digits.contains(request.digit) else {
			return
		}

		cells[selectedIndex] = request.digit
		presenter.presentBoardChanged(.init(state: makeState()))
	}

	func clearCell(_ request: Model.ClearCell.Request) {
		guard let selectedIndex else {
			return
		}

		cells[selectedIndex] = nil
		presenter.presentBoardChanged(.init(state: makeState()))
	}

	func validatePuzzle(_ request: Model.Validate.Request) {
		runValidation { [weak self] result in
			self?.presenter.presentValidate(.init(result: result))
		}
	}

	func savePuzzle(_ request: Model.Save.Request) {
		let now: Date = Date()
		let puzzle: UserPuzzle = UserPuzzle(
			id: puzzleId,
			createdAt: createdAt,
			updatedAt: now,
			puzzle: makeGrid()
		)
		UserPuzzleStore.shared.save(puzzle)
		presenter.presentSave(.init(isSaved: true))
	}

	func playPuzzle(_ request: Model.Play.Request) {
		runValidation { [weak self] result in
			switch result {
			case .valid(let puzzle, let solution):
				self?.presenter.presentPlay(.init(puzzle: puzzle, solution: solution))
			default:
				self?.presenter.presentValidate(.init(result: result))
			}
		}
	}

	func sharePuzzle(_ request: Model.Share.Request) {
		let grid: [[Int]] = makeGrid()
		if let code: String = PuzzleCodec.encode(grid: grid) {
			presenter.presentShare(.init(code: code))
		} else {
			presenter.presentShare(.init(code: ""))
		}
	}

	func importPuzzle(_ request: Model.Import.Request) {
		guard let grid: [[Int]] = PuzzleCodec.decode(request.code) else {
			presenter.presentImport(.init(isImported: false))
			return
		}

		cells = PuzzleEditorInteractor.flatten(grid)
		presenter.presentBoardChanged(.init(state: makeState()))
		presenter.presentImport(.init(isImported: true))
	}

	// MARK: - Private methods
	private func makeState() -> Model.EditorState {
		let cellStates: [Model.CellState] = cells.map { value in
			Model.CellState(value: value)
		}
		return Model.EditorState(
			cells: cellStates,
			selectedIndex: selectedIndex,
			statusText: statusText
		)
	}

	private func makeGrid() -> [[Int]] {
		var grid: [[Int]] = Array(
			repeating: Array(repeating: 0, count: Const.sideLength),
			count: Const.sideLength
		)

		for index in 0..<Const.cellCount {
			let row: Int = index / Const.sideLength
			let col: Int = index % Const.sideLength
			grid[row][col] = cells[index] ?? 0
		}

		return grid
	}

	private static func flatten(_ grid: [[Int]]) -> [Int?] {
		var result: [Int?] = Array(repeating: nil, count: Const.cellCount)
		guard grid.count == Const.sideLength else {
			return result
		}

		for row in 0..<Const.sideLength {
			guard grid[row].count == Const.sideLength else {
				return result
			}
		}

		for row in 0..<Const.sideLength {
			for col in 0..<Const.sideLength {
				let value: Int = grid[row][col]
				result[(row * Const.sideLength) + col] = value == 0 ? nil : value
			}
		}

		return result
	}

	private func runValidation(completion: @escaping (Model.ValidationResult) -> Void) {
		let token: UUID = UUID()
		validationToken = token
		let grid: [[Int]] = makeGrid()

		DispatchQueue.global(qos: .userInitiated).async {
			let engine: SudokuEngine = SudokuEngine()
			let validation: ValidationResult = engine.validate(board: grid)
			let result: Model.ValidationResult

			if validation != .ok {
				result = .invalid(message: self.makeValidationMessage(validation))
			} else if engine.hasUniqueSolution(board: grid) == false {
				result = .invalid(message: Const.noUniqueMessage)
			} else {
				if let solved: [[Int]] = try? engine.solve(board: grid) {
					result = .valid(puzzle: grid, solution: solved)
				} else {
					result = .invalid(message: Const.noSolutionMessage)
				}
			}

			DispatchQueue.main.async { [weak self] in
				guard self?.validationToken == token else {
					return
				}
				self?.validationToken = nil
				completion(result)
			}
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + Const.validationTimeoutSeconds) { [weak self] in
			guard let self, self.validationToken == token else {
				return
			}
			self.validationToken = nil
			completion(.timeout)
		}
	}

	private func makeValidationMessage(_ validation: ValidationResult) -> String {
		switch validation {
		case .ok:
			return Const.defaultStatus
		case .invalidSize:
			return Const.invalidSizeMessage
		case .invalidValue:
			return Const.invalidValueMessage
		case .rowDuplicate, .colDuplicate, .boxDuplicate:
			return Const.duplicateMessage
		}
	}
}
