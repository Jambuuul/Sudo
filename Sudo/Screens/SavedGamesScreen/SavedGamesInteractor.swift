//
//  SavedGamesInteractor.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

final class SavedGamesInteractor: SavedGamesBusinessLogic {
	// MARK: - Fields
	private let presenter: SavedGamesPresentationLogic

	// MARK: - Lifecycle
	init(presenter: SavedGamesPresentationLogic) {
		self.presenter = presenter
	}

	// MARK: - BusinessLogic
	func loadOpenGame(_ request: Model.OpenGame.Request) {
		presenter.presentOpenGame(.init(game: request.game))
	}
}
