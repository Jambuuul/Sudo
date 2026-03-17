//
//  Model.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//


enum MainMenuModel {
    enum Start {
        struct Request { }
        struct Response { }
        struct ViewModel { }
    }
	
	enum NewGame {
		struct Request {
			let difficulty: SudokuDifficulty
		}

		struct Response {
			let difficulty: SudokuDifficulty
		}

		struct ViewModel { }
	}

    //    enum Other {
    //        struct Request { }
    //        struct Response { }
    //        struct ViewModel { }
    //    }
}
