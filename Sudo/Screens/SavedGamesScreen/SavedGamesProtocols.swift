//
//  SavedGamesProtocols.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

protocol SavedGamesBusinessLogic {
	typealias Model = SavedGamesModel
	func loadOpenGame(_ request: Model.OpenGame.Request)
}

protocol SavedGamesPresentationLogic {
	typealias Model = SavedGamesModel
	func presentOpenGame(_ response: Model.OpenGame.Response)
}
