//
//  Interactor.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//


import Foundation

final class BoardInteractor: BoardBusinessLogic {
    // MARK: - Fields
	private let presenter: BoardPresentationLogic
	private let gameId: UUID
	private let difficulty: SudokuDifficulty
	private var gameName: String
    private var board: SudokuBoard
	private var elapsedSeconds: Int
	private var mistakeCount: Int
	private let killerCages: [KillerCage]
    private var selectedIndex: Int?
	private var timer: Timer?
	private var didRecordStats: Bool = false

    // MARK: - Lifecycle
	init(
		presenter: BoardPresentationLogic,
		source: BoardStartSource
	) {
        self.presenter = presenter
		switch source {
		case .newGame(let difficulty):
			self.gameId = UUID()
			self.difficulty = difficulty
			self.gameName = BoardInteractor.makeDefaultGameName(difficulty: difficulty)
			self.elapsedSeconds = 0
			self.mistakeCount = 0
			self.killerCages = []
			self.board = BoardInteractor.makeBoard(difficulty: difficulty)
		case .savedGame(let game):
			self.gameId = game.id
			self.difficulty = game.difficulty
			self.gameName = game.name
			self.elapsedSeconds = game.elapsedSeconds
			self.mistakeCount = game.mistakeCount
			self.killerCages = game.killerCages
			self.board = BoardInteractor.makeBoard(from: game)
		case .customPuzzle(let puzzle, let solution):
			self.gameId = UUID()
			self.difficulty = .custom
			self.gameName = BoardInteractor.makeDefaultGameName(difficulty: .custom)
			self.elapsedSeconds = 0
			self.mistakeCount = 0
			self.killerCages = []
			self.board = BoardInteractor.makeBoard(puzzle: puzzle, solution: solution)
		case .networkPuzzle(let difficulty, let puzzle, let solution):
			self.gameId = UUID()
			self.difficulty = difficulty
			self.gameName = BoardInteractor.makeDefaultGameName(difficulty: difficulty)
			self.elapsedSeconds = 0
			self.mistakeCount = 0
			self.killerCages = []
			self.board = BoardInteractor.makeBoard(puzzle: puzzle, solution: solution)
		case .killerPuzzle(let difficulty, let puzzle, let solution, let cages):
			self.gameId = UUID()
			self.difficulty = difficulty
			self.gameName = BoardInteractor.makeDefaultKillerGameName(difficulty: difficulty)
			self.elapsedSeconds = 0
			self.mistakeCount = 0
			self.killerCages = cages
			self.board = BoardInteractor.makeBoard(puzzle: puzzle, solution: solution)
		}
    }

    // MARK: - BusinessLogic
    func loadStart(_ request: Model.Start.Request) {
        presenter.presentStart(
            Model.Start.Response(
                state: makeState()
            )
        )
		startTimerIfNeeded()
    }

    func selectCell(_ request: Model.SelectCell.Request) {
        guard (0..<board.cellCount).contains(request.index) else {
            return
        }

        selectedIndex = request.index
        presenter.presentBoardChanged(
            Model.BoardChanged.Response(
                state: makeState()
            )
        )
    }

    func inputDigit(_ request: Model.InputDigit.Request) {
        guard let selectedIndex else {
            return
        }

        guard board.updateValue(request.digit, at: selectedIndex) else {
            return
        }

		if board.cell(at: selectedIndex)?.isCorrect == false {
			mistakeCount += 1
		}

        presenter.presentBoardChanged(
            Model.BoardChanged.Response(
                state: makeState()
            )
        )
		handleSolvedIfNeeded()
    }

    func clearCell(_ request: Model.ClearCell.Request) {
        guard let selectedIndex else {
            return
        }

        guard board.updateValue(nil, at: selectedIndex) else {
            return
        }

        presenter.presentBoardChanged(
            Model.BoardChanged.Response(
                state: makeState()
            )
        )
		handleSolvedIfNeeded()
    }

	func saveGame(_ request: Model.SaveGame.Request) {
		let existing: SavedGame? = SavedGameStore.shared.load(id: gameId)
		let createdAt: Date = existing?.createdAt ?? Date()
		let now: Date = Date()
		let name: String = request.name.trimmingCharacters(in: .whitespacesAndNewlines)
		gameName = name.isEmpty ? gameName : name

		let game: SavedGame = SavedGame(
			id: gameId,
			createdAt: createdAt,
			updatedAt: now,
			name: gameName,
			difficulty: difficulty,
			puzzle: makePuzzleValues(),
			solution: makeSolutionValues(),
			current: makeCurrentValues(),
			elapsedSeconds: elapsedSeconds,
			mistakeCount: mistakeCount,
			killerCages: killerCages
		)

		SavedGameStore.shared.save(game)

		presenter.presentSaveGame(
			Model.SaveGame.Response(isSaved: true)
		)
	}

	deinit {
		timer?.invalidate()
	}

    // MARK: - Private methods
	private static func makeBoard(difficulty: SudokuDifficulty) -> SudokuBoard {
		let puzzle: GeneratedPuzzle = SudokuEngine().generate(difficulty: difficulty)
		let template: SudokuBoard.PuzzleTemplate = SudokuBoard.PuzzleTemplate(
			puzzle: puzzle.puzzle,
			solution: puzzle.solution
		)
		return SudokuBoard(template: template)
	}

	private static func makeBoard(from game: SavedGame) -> SudokuBoard {
		let template: SudokuBoard.PuzzleTemplate = SudokuBoard.PuzzleTemplate(
			puzzle: game.puzzle,
			solution: game.solution
		)
		var board: SudokuBoard = SudokuBoard(template: template)
		let side: Int = SudokuBoard.sideLength

		guard game.current.count == side else {
			return board
		}

		for row in 0..<side {
			guard game.current[row].count == side else {
				return board
			}
		}

		for row in 0..<side {
			for col in 0..<side {
				let value: Int = game.current[row][col]
				if value != 0 {
					let index: Int = row * side + col
					_ = board.updateValue(value, at: index)
				}
			}
		}

		return board
	}

	private static func makeBoard(puzzle: [[Int]], solution: [[Int]]) -> SudokuBoard {
		let template: SudokuBoard.PuzzleTemplate = SudokuBoard.PuzzleTemplate(
			puzzle: puzzle,
			solution: solution
		)
		return SudokuBoard(template: template)
	}

    private func makeState() -> Model.GameState {
        let cells: [Model.CellState] = board.cells.map { cell in
            Model.CellState(
                value: cell.value,
                isGiven: cell.isGiven,
                isIncorrect: !cell.isCorrect
            )
        }

        return Model.GameState(
            cells: cells,
			selectedIndex: selectedIndex,
			isSolved: board.isSolved,
			elapsedSeconds: elapsedSeconds,
			mistakeCount: mistakeCount,
			difficulty: difficulty,
			gameName: gameName,
			killerCages: killerCages
        )
    }

	private func startTimerIfNeeded() {
		guard timer == nil else {
			return
		}

		guard !board.isSolved else {
			return
		}

		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
			self?.handleTimerTick()
		}
	}

	private func stopTimerIfSolved() {
		guard board.isSolved else {
			return
		}

		timer?.invalidate()
		timer = nil
		recordStatsIfNeeded()
	}

	private func handleSolvedIfNeeded() {
		guard board.isSolved else {
			return
		}

		let shouldPresentAlert: Bool = !didRecordStats
		stopTimerIfSolved()
		if shouldPresentAlert {
			presenter.presentGameSolved(
				Model.GameSolved.Response(state: makeState())
			)
		}
	}

	private func recordStatsIfNeeded() {
		guard !didRecordStats else {
			return
		}

		didRecordStats = true
		let record: GameStatRecord = GameStatRecord(
			id: gameId,
			completedAt: Date(),
			difficulty: difficulty,
			elapsedSeconds: elapsedSeconds,
			mistakeCount: mistakeCount
		)
		GameStatsStore.shared.save(record)
	}

	private func handleTimerTick() {
		guard !board.isSolved else {
			stopTimerIfSolved()
			return
		}

		elapsedSeconds += 1
		presenter.presentTimerTick(
			Model.TimerTick.Response(elapsedSeconds: elapsedSeconds)
		)
	}

	private func makeEmptyGrid() -> [[Int]] {
		Array(
			repeating: Array(repeating: 0, count: SudokuBoard.sideLength),
			count: SudokuBoard.sideLength
		)
	}

	private func makeCurrentValues() -> [[Int]] {
		var grid: [[Int]] = makeEmptyGrid()

		for cell in board.cells {
			let row: Int = cell.position.row
			let col: Int = cell.position.column
			grid[row][col] = cell.value ?? 0
		}

		return grid
	}

	private func makePuzzleValues() -> [[Int]] {
		var grid: [[Int]] = makeEmptyGrid()

		for cell in board.cells {
			let row: Int = cell.position.row
			let col: Int = cell.position.column
			grid[row][col] = cell.isGiven ? (cell.value ?? cell.solution) : 0
		}

		return grid
	}

	private func makeSolutionValues() -> [[Int]] {
		var grid: [[Int]] = makeEmptyGrid()

		for cell in board.cells {
			let row: Int = cell.position.row
			let col: Int = cell.position.column
			grid[row][col] = cell.solution
		}

		return grid
	}

	private static func makeDefaultGameName(difficulty: SudokuDifficulty) -> String {
		switch difficulty {
		case .veryEasy:
			return "Very Easy Game"
		case .easy:
			return "Easy Game"
		case .medium:
			return "Medium Game"
		case .hard:
			return "Hard Game"
		case .expert:
			return "Expert Game"
		case .master:
			return "Master Game"
		case .custom:
			return "Custom Game"
		}
	}

	private static func makeDefaultKillerGameName(difficulty: SudokuDifficulty) -> String {
		"Killer \(makeDefaultGameName(difficulty: difficulty))"
	}
}
