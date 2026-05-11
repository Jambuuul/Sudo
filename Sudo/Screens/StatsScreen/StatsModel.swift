//
//  StatsModel.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

enum StatsModel {
	enum Period: Int {
		case lastDay
		case week
		case allTime
	}

	enum DifficultyFilter: Equatable {
		case all
		case difficulty(SudokuDifficulty)
	}

	struct StatItem {
		let title: String
		let value: String
	}

	struct StatsSummary {
		let completedGames: Int
		let averageTime: Int
		let bestTime: Int
		let averageMistakes: Double
		let totalMistakes: Int
		let cleanGames: Int
	}

	enum LoadStats {
		struct Request {
			let period: Period
			let difficulty: DifficultyFilter
		}
		struct Response {
			let period: Period
			let difficulty: DifficultyFilter
			let summary: StatsSummary
		}
		struct ViewModel {
			let titleText: String
			let difficultyText: String
			let items: [StatItem]
			let emptyText: String
			let isEmpty: Bool
		}
	}

	enum DifficultySelection {
		struct Request {
			let difficulty: DifficultyFilter
		}
	}
}
