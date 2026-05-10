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
		static let solvedTitle: String = "Victory"
		static let solvedMessageFormat: String = "Difficulty: %@\nTime: %@\nMistakes: %d"
		static let killerTitleFormat: String = "Killer %@"
		static let boardSize: Int = SudokuBoard.sideLength
    }

	private typealias CageInfo = (sumText: String?, borders: Model.CageBorders)

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

	func presentGameSolved(_ response: Model.GameSolved.Response) {
		let difficultyText: String = makeDifficultyTitle(response.state.difficulty)
		let timeText: String = TimeFormatter.makeTimeText(elapsedSeconds: response.state.elapsedSeconds)
		let message: String = String(
			format: Const.solvedMessageFormat,
			difficultyText,
			timeText,
			response.state.mistakeCount
		)

		view?.displayGameSolved(
			Model.GameSolved.ViewModel(
				title: Const.solvedTitle,
				message: message
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

			let selectedCell: Model.CellState = state.cells[selectedIndex]
			let isCorrectFilled: Bool = selectedCell.value != nil && !selectedCell.isIncorrect
            return !selectedCell.isGiven && !isCorrectFilled
        }()

		let completedDigits: Set<Int> = makeCompletedDigits(cells: state.cells)
		let duplicateRowsAndColumns: (rows: Set<Int>, columns: Set<Int>) = makeDuplicateRowsAndColumns(
			cells: state.cells,
			selectedValue: selectedValue
		)
		let cageInfoByIndex: [Int: CageInfo] = makeCageInfoByIndex(cages: state.killerCages)

        let cells: [Model.CellViewModel] = state.cells.enumerated().map { index, cell in
			let row: Int = index / Const.boardSize
			let column: Int = index % Const.boardSize
			let isInDuplicateRowOrColumn: Bool =
			duplicateRowsAndColumns.rows.contains(row) ||
			duplicateRowsAndColumns.columns.contains(column)
			let cageInfo: CageInfo? = cageInfoByIndex[index]

			return Model.CellViewModel(
                valueText: cell.value.map(String.init) ?? "",
                isGiven: cell.isGiven,
                isSelected: selectedIndex == index,
                isIncorrect: cell.isIncorrect,
				isMatchingSelectedValue: cell.value != nil && cell.value == selectedValue,
				isInDuplicateRowOrColumn: isInDuplicateRowOrColumn,
				cageSumText: cageInfo?.sumText,
				cageBorders: cageInfo?.borders
            )
        }

        return Model.BoardViewModel(
            titleText: makeTitle(difficulty: state.difficulty, hasKillerCages: !state.killerCages.isEmpty),
			gameName: state.gameName,
            statusText: state.isSolved ? Const.solvedStatusText : Const.inProgressStatusText,
			timeText: TimeFormatter.makeTimeText(elapsedSeconds: state.elapsedSeconds),
            cells: cells,
            hasSelection: hasEditableSelection,
			completedDigits: completedDigits,
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

	private func makeTitle(difficulty: SudokuDifficulty, hasKillerCages: Bool) -> String {
		let difficultyTitle: String = makeDifficultyTitle(difficulty)
		guard hasKillerCages else {
			return difficultyTitle
		}

		return String(format: Const.killerTitleFormat, difficultyTitle)
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

	private func makeCompletedDigits(cells: [Model.CellState]) -> Set<Int> {
		var counts: [Int: Int] = [:]

		for cell in cells {
			guard let value: Int = cell.value, !cell.isIncorrect else {
				continue
			}

			counts[value, default: 0] += 1
		}

		var result: Set<Int> = []
		for digit in SudokuBoard.digits where counts[digit] == Const.boardSize {
			result.insert(digit)
		}

		return result
	}

	private func makeCageInfoByIndex(cages: [KillerCage]) -> [Int: CageInfo] {
		var result: [Int: CageInfo] = [:]
		let cageIDByIndex: [Int: Int] = makeCageIDByIndex(cages: cages)

		for cage in cages {
			guard let firstCell: Int = cage.cells.min() else {
				continue
			}

			for cell in cage.cells {
				let row: Int = cell / Const.boardSize
				let column: Int = cell % Const.boardSize
				let topIndex: Int = cell - Const.boardSize
				let leftIndex: Int = cell - 1
				let bottomIndex: Int = cell + Const.boardSize
				let rightIndex: Int = cell + 1

				result[cell] = (
					sumText: cell == firstCell ? String(cage.sum) : nil,
					borders: Model.CageBorders(
						showsTop: row == 0 || cageIDByIndex[topIndex] != cage.id,
						showsLeft: column == 0 || cageIDByIndex[leftIndex] != cage.id,
						showsBottom: row == Const.boardSize - 1 || cageIDByIndex[bottomIndex] != cage.id,
						showsRight: column == Const.boardSize - 1 || cageIDByIndex[rightIndex] != cage.id
					)
				)
			}
		}

		return result
	}

	private func makeCageIDByIndex(cages: [KillerCage]) -> [Int: Int] {
		var result: [Int: Int] = [:]

		for cage in cages {
			for cell in cage.cells {
				result[cell] = cage.id
			}
		}

		return result
	}
}
