//
//  PuzzleEditorModel.swift
//  Sudo
//
//  Created by Jam on 17.03.2026.
//

enum PuzzleEditorModel {
	struct CellState {
		let value: Int?
	}

	struct EditorState {
		let cells: [CellState]
		let selectedIndex: Int?
		let statusText: String
	}

	struct CellViewModel {
		let valueText: String
		let isSelected: Bool
	}

	struct EditorViewModel {
		let titleText: String
		let statusText: String
		let cells: [CellViewModel]
		let hasSelection: Bool
	}

	enum Start {
		struct Request { }
		struct Response {
			let state: EditorState
		}
		struct ViewModel {
			let board: EditorViewModel
		}
	}

	enum BoardChanged {
		struct Response {
			let state: EditorState
		}
		struct ViewModel {
			let board: EditorViewModel
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

	enum Validate {
		struct Request { }
		struct Response {
			let result: ValidationResult
		}
		struct ViewModel {
			let title: String
			let message: String
		}
	}

	enum Save {
		struct Request { }
		struct Response {
			let isSaved: Bool
		}
		struct ViewModel {
			let title: String
			let message: String
		}
	}

	enum Share {
		struct Request { }
		struct Response {
			let code: String
		}
		struct ViewModel {
			let title: String
			let message: String
			let code: String
		}
	}

	enum Import {
		struct Request {
			let code: String
		}
		struct Response {
			let isImported: Bool
		}
		struct ViewModel {
			let title: String
			let message: String
		}
	}

	enum Play {
		struct Request { }
		struct Response {
			let puzzle: [[Int]]
			let solution: [[Int]]
		}
	}

	enum ValidationResult {
		case valid(puzzle: [[Int]], solution: [[Int]])
		case invalid(message: String)
		case timeout
	}
}
