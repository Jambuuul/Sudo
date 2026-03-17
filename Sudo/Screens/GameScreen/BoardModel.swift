//
//  Model.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//


enum BoardModel {
    struct CellState {
        let value: Int?
        let isGiven: Bool
        let isIncorrect: Bool
    }

    struct GameState {
        let cells: [CellState]
        let selectedIndex: Int?
        let isSolved: Bool
		let elapsedSeconds: Int
		let difficulty: SudokuDifficulty
    }

    struct CellViewModel {
        let valueText: String
        let isGiven: Bool
        let isSelected: Bool
        let isIncorrect: Bool
        let isMatchingSelectedValue: Bool
		let isInDuplicateRowOrColumn: Bool
    }

    struct BoardViewModel {
        let titleText: String
        let statusText: String
		let timeText: String
        let cells: [CellViewModel]
        let hasSelection: Bool
        let isSolved: Bool
    }

    enum Start {
        struct Request { }
        struct Response {
            let state: GameState
        }

        struct ViewModel {
            let board: BoardViewModel
        }
    }

    enum BoardChanged {
        struct Response {
            let state: GameState
        }

        struct ViewModel {
            let board: BoardViewModel
        }
    }

	enum TimerTick {
		struct Response {
			let elapsedSeconds: Int
		}

		struct ViewModel {
			let timeText: String
		}
	}

    enum SelectCell {
        struct Request {
            let index: Int
        }
    }

    enum InputDigit {
        struct Request {
            let digit: Int
        }
    }

    enum ClearCell {
        struct Request { }
    }

	enum SaveGame {
		struct Request { }

		struct Response {
			let isSaved: Bool
		}

		struct ViewModel {
			let title: String
			let message: String
		}
	}

    //    enum Other {
    //        struct Request { }
    //        struct Response { }
    //        struct ViewModel { }
    //    }
}
