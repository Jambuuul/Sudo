//
//  SavedGameStore.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

import Foundation

struct SavedGame: Codable, Equatable {
	let id: UUID
	let createdAt: Date
	let updatedAt: Date
	let difficulty: SudokuDifficulty
	let puzzle: [[Int]]
	let solution: [[Int]]
	let current: [[Int]]
	let elapsedSeconds: Int
}

final class SavedGameStore {
	// MARK: - Constants
	private enum Const {
		static let storageKey: String = "saved_games_v1"
	}

	// MARK: - Static
	static let shared: SavedGameStore = SavedGameStore()

	// MARK: - Fields
	private let defaults: UserDefaults

	// MARK: - Lifecycle
	init(defaults: UserDefaults = .standard) {
		self.defaults = defaults
	}

	// MARK: - Public methods
	func loadAll() -> [SavedGame] {
		guard let data = defaults.data(forKey: Const.storageKey) else {
			return []
		}

		do {
			return try makeDecoder().decode([SavedGame].self, from: data)
		} catch {
			do {
				return try JSONDecoder().decode([SavedGame].self, from: data)
			} catch {
				return []
			}
		}
	}

	func load(id: UUID) -> SavedGame? {
		loadAll().first { $0.id == id }
	}

	func save(_ game: SavedGame) {
		var games: [SavedGame] = loadAll()
		if let index = games.firstIndex(where: { $0.id == game.id }) {
			games[index] = game
		} else {
			games.append(game)
		}

		persist(games)
	}

	func delete(id: UUID) {
		let games: [SavedGame] = loadAll().filter { $0.id != id }
		persist(games)
	}

	// MARK: - Private methods
	private func persist(_ games: [SavedGame]) {
		do {
			let data = try makeEncoder().encode(games)
			defaults.set(data, forKey: Const.storageKey)
		} catch {
			return
		}
	}

	private func makeEncoder() -> JSONEncoder {
		let encoder: JSONEncoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		return encoder
	}

	private func makeDecoder() -> JSONDecoder {
		let decoder: JSONDecoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}
}
