//
//  SavedGamesModel.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

enum SavedGamesModel {
	enum OpenGame {
		struct Request {
			let game: SavedGame
		}

		struct Response {
			let game: SavedGame
		}

		struct ViewModel { }
	}
}
