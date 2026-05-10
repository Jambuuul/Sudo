//
//  GameStatsStore.swift
//  Sudo
//
//  Created by Jam on 09.05.2026.
//

import Foundation

struct GameStatRecord: Codable, Equatable {
	let id: UUID
	let completedAt: Date
	let difficulty: SudokuDifficulty
	let elapsedSeconds: Int
	let mistakeCount: Int
}

final class GameStatsStore {
	// MARK: - Constants
	private enum Const {
		static let storageKey: String = "game_stats_v1"
	}

	// MARK: - Static
	static let shared: GameStatsStore = GameStatsStore()

	// MARK: - Fields
	private let defaults: UserDefaults

	// MARK: - Lifecycle
	init(defaults: UserDefaults = .standard) {
		self.defaults = defaults
	}

	// MARK: - Public methods
	func loadAll() -> [GameStatRecord] {
		guard let data = defaults.data(forKey: Const.storageKey) else {
			return []
		}

		do {
			return try makeDecoder().decode([GameStatRecord].self, from: data)
		} catch {
			return []
		}
	}

	func save(_ record: GameStatRecord) {
		var records: [GameStatRecord] = loadAll()
		if let index = records.firstIndex(where: { $0.id == record.id }) {
			records[index] = record
		} else {
			records.append(record)
		}

		persist(records)
	}

	// MARK: - Private methods
	private func persist(_ records: [GameStatRecord]) {
		do {
			let data = try makeEncoder().encode(records)
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
