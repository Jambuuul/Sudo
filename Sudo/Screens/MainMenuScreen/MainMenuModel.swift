//
//  Model.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//


enum MainMenuModel {
	enum NewGameSource {
		case local
		case network
		case killerNetwork
	}

    enum Start {
        struct Request { }
        struct Response { }
        struct ViewModel { }
    }
	
	enum NewGame {
		struct Request {
			let difficulty: SudokuDifficulty
			let source: NewGameSource
		}

		struct Response {
			let difficulty: SudokuDifficulty
			let puzzle: [[Int]]?
			let solution: [[Int]]?
			let cages: [KillerCage]?
		}

		struct ViewModel { }
	}

	enum NetworkLoading {
		struct Response { }
		struct ViewModel {
			let title: String
			let message: String
		}
	}

	enum NetworkFailure {
		struct Response { }
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
