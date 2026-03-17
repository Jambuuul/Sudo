//
//  UserPuzzleStore.swift
//  Sudo
//
//  Created by Jam on 17.03.2026.
//

import Foundation

struct UserPuzzle: Codable, Equatable {
	let id: UUID
	let createdAt: Date
	let updatedAt: Date
	let puzzle: [[Int]]
}

final class UserPuzzleStore {
	// MARK: - Constants
	private enum Const {
		static let storageKey: String = "user_puzzles_v1"
	}

	// MARK: - Static
	static let shared: UserPuzzleStore = UserPuzzleStore()

	// MARK: - Fields
	private let defaults: UserDefaults

	// MARK: - Lifecycle
	init(defaults: UserDefaults = .standard) {
		self.defaults = defaults
	}

	// MARK: - Public methods
	func loadAll() -> [UserPuzzle] {
		guard let data = defaults.data(forKey: Const.storageKey) else {
			return []
		}

		do {
			return try makeDecoder().decode([UserPuzzle].self, from: data)
		} catch {
			do {
				return try JSONDecoder().decode([UserPuzzle].self, from: data)
			} catch {
				return []
			}
		}
	}

	func save(_ puzzle: UserPuzzle) {
		var puzzles: [UserPuzzle] = loadAll()
		if let index = puzzles.firstIndex(where: { $0.id == puzzle.id }) {
			puzzles[index] = puzzle
		} else {
			puzzles.append(puzzle)
		}

		persist(puzzles)
	}

	func delete(id: UUID) {
		let puzzles: [UserPuzzle] = loadAll().filter { $0.id != id }
		persist(puzzles)
	}

	// MARK: - Private methods
	private func persist(_ puzzles: [UserPuzzle]) {
		do {
			let data = try makeEncoder().encode(puzzles)
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
