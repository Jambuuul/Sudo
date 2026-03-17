//
//  Presenter.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//

import Foundation

final class BoardPresenter: BoardPresentationLogic {
    // MARK: - Constants
    private enum Const {
        static let solvedStatusText: String = "Puzzle solved."
        static let inProgressStatusText: String = "Select a cell and fill digits 1...9."
		static let saveTitle: String = "Saved"
		static let saveMessage: String = "Game saved successfully."
		static let boardSize: Int = SudokuBoard.sideLength
    }

    weak var view: BoardDisplayLogic?

    // MARK: - PresentationLogic
    func presentStart(_ response: Model.Start.Response) {
        let boardViewModel: Model.BoardViewModel = makeBoardViewModel(from: response.state)
        view?.displayStart(
            Model.Start.ViewModel(board: boardViewModel)
        )
    }

    func presentBoardChanged(_ response: Model.BoardChanged.Response) {
        let boardViewModel: Model.BoardViewModel = makeBoardViewModel(from: response.state)
        view?.displayBoardChanged(
            Model.BoardChanged.ViewModel(board: boardViewModel)
        )
    }

	func presentTimerTick(_ response: Model.TimerTick.Response) {
		let timeText: String = TimeFormatter.makeTimeText(elapsedSeconds: response.elapsedSeconds)
		view?.displayTimerTick(
			Model.TimerTick.ViewModel(timeText: timeText)
		)
	}

	func presentSaveGame(_ response: Model.SaveGame.Response) {
		guard response.isSaved else {
			return
		}

		view?.displaySaveGame(
			Model.SaveGame.ViewModel(
				title: Const.saveTitle,
				message: Const.saveMessage
			)
		)
	}

    // MARK: - Private methods
    private func makeBoardViewModel(from state: Model.GameState) -> Model.BoardViewModel {
        let selectedIndex: Int? = state.selectedIndex
        let selectedValue: Int? = {
            guard
                let selectedIndex,
                state.cells.indices.contains(selectedIndex)
            else {
                return nil
            }

            return state.cells[selectedIndex].value
        }()

        let hasEditableSelection: Bool = {
            guard
                let selectedIndex,
                state.cells.indices.contains(selectedIndex)
            else {
                return false
            }

            return !state.cells[selectedIndex].isGiven
        }()

		let duplicateRowsAndColumns: (rows: Set<Int>, columns: Set<Int>) = makeDuplicateRowsAndColumns(
			cells: state.cells,
			selectedValue: selectedValue
		)

        let cells: [Model.CellViewModel] = state.cells.enumerated().map { index, cell in
			let row: Int = index / Const.boardSize
			let column: Int = index % Const.boardSize
			let isInDuplicateRowOrColumn: Bool =
			duplicateRowsAndColumns.rows.contains(row) ||
			duplicateRowsAndColumns.columns.contains(column)

			return Model.CellViewModel(
                valueText: cell.value.map(String.init) ?? "",
                isGiven: cell.isGiven,
                isSelected: selectedIndex == index,
                isIncorrect: cell.isIncorrect,
                isMatchingSelectedValue: cell.value != nil && cell.value == selectedValue,
				isInDuplicateRowOrColumn: isInDuplicateRowOrColumn
            )
        }

        return Model.BoardViewModel(
            titleText: makeDifficultyTitle(state.difficulty),
            statusText: state.isSolved ? Const.solvedStatusText : Const.inProgressStatusText,
			timeText: TimeFormatter.makeTimeText(elapsedSeconds: state.elapsedSeconds),
            cells: cells,
            hasSelection: hasEditableSelection,
            isSolved: state.isSolved
        )
    }

	private func makeDifficultyTitle(_ difficulty: SudokuDifficulty) -> String {
		switch difficulty {
		case .veryEasy:
			return "Very Easy"
		case .easy:
			return "Easy"
		case .medium:
			return "Medium"
		case .hard:
			return "Hard"
		case .expert:
			return "Expert"
		case .master:
			return "Master"
		case .custom:
			return "Custom"
		}
	}

	private func makeDuplicateRowsAndColumns(
		cells: [Model.CellState],
		selectedValue: Int?
	) -> (rows: Set<Int>, columns: Set<Int>) {
		guard let selectedValue else {
			return (rows: [], columns: [])
		}

		var rowCounts: [Int] = Array(repeating: 0, count: Const.boardSize)
		var columnCounts: [Int] = Array(repeating: 0, count: Const.boardSize)

		for (index, cell) in cells.enumerated() {
			guard cell.value == selectedValue else {
				continue
			}

			let row: Int = index / Const.boardSize
			let column: Int = index % Const.boardSize
			rowCounts[row] += 1
			columnCounts[column] += 1
		}

		var rows: Set<Int> = []
		var columns: Set<Int> = []

		for row in 0..<Const.boardSize where rowCounts[row] > 1 {
			rows.insert(row)
		}

		for column in 0..<Const.boardSize where columnCounts[column] > 1 {
			columns.insert(column)
		}

		return (rows: rows, columns: columns)
	}
}
