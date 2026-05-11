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
	let name: String
	let difficulty: SudokuDifficulty
	let puzzle: [[Int]]
	let solution: [[Int]]
	let current: [[Int]]
	let elapsedSeconds: Int
	let mistakeCount: Int

	private enum CodingKeys: String, CodingKey {
		case id
		case createdAt
		case updatedAt
		case name
		case difficulty
		case puzzle
		case solution
		case current
		case elapsedSeconds
		case mistakeCount
	}

	init(
		id: UUID,
		createdAt: Date,
		updatedAt: Date,
		name: String,
		difficulty: SudokuDifficulty,
		puzzle: [[Int]],
		solution: [[Int]],
		current: [[Int]],
		elapsedSeconds: Int,
		mistakeCount: Int
	) {
		self.id = id
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.name = name
		self.difficulty = difficulty
		self.puzzle = puzzle
		self.solution = solution
		self.current = current
		self.elapsedSeconds = elapsedSeconds
		self.mistakeCount = mistakeCount
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(UUID.self, forKey: .id)
		createdAt = try container.decode(Date.self, forKey: .createdAt)
		updatedAt = try container.decode(Date.self, forKey: .updatedAt)
		name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Saved Game"
		difficulty = try container.decode(SudokuDifficulty.self, forKey: .difficulty)
		puzzle = try container.decode([[Int]].self, forKey: .puzzle)
		solution = try container.decode([[Int]].self, forKey: .solution)
		current = try container.decode([[Int]].self, forKey: .current)
		elapsedSeconds = try container.decode(Int.self, forKey: .elapsedSeconds)
		mistakeCount = try container.decodeIfPresent(Int.self, forKey: .mistakeCount) ?? 0
	}
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
