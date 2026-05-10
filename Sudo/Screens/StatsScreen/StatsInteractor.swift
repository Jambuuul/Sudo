//
//  StatsInteractor.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

import Foundation

final class StatsInteractor: StatsBusinessLogic {
	typealias Model = StatsModel

	// MARK: - Fields
	private let presenter: StatsPresentationLogic
	private let statsStore: GameStatsStore

	// MARK: - Lifecycle
	init(
		presenter: StatsPresentationLogic,
		statsStore: GameStatsStore = .shared
	) {
		self.presenter = presenter
		self.statsStore = statsStore
	}

	// MARK: - BusinessLogic
	func loadStats(_ request: Model.LoadStats.Request) {
		let records: [GameStatRecord] = statsStore.loadAll()
		let filteredRecords: [GameStatRecord] = filter(
			records: records,
			period: request.period,
			difficulty: request.difficulty
		)
		let summary: Model.StatsSummary = makeSummary(records: filteredRecords)

		presenter.presentStats(
			.init(
				period: request.period,
				difficulty: request.difficulty,
				summary: summary
			)
		)
	}

	// MARK: - Private methods
	private func filter(
		records: [GameStatRecord],
		period: Model.Period,
		difficulty: Model.DifficultyFilter
	) -> [GameStatRecord] {
		let now: Date = Date()
		let lowerBound: Date?

		switch period {
		case .lastDay:
			lowerBound = Calendar.current.date(byAdding: .day, value: -1, to: now)
		case .week:
			lowerBound = Calendar.current.date(byAdding: .day, value: -7, to: now)
		case .allTime:
			lowerBound = nil
		}

		return records.filter { record in
			let matchesPeriod: Bool
			if let lowerBound {
				matchesPeriod = record.completedAt >= lowerBound
			} else {
				matchesPeriod = true
			}

			let matchesDifficulty: Bool
			switch difficulty {
			case .all:
				matchesDifficulty = true
			case .difficulty(let selectedDifficulty):
				matchesDifficulty = record.difficulty == selectedDifficulty
			}

			return matchesPeriod && matchesDifficulty
		}
	}

	private func makeSummary(records: [GameStatRecord]) -> Model.StatsSummary {
		guard !records.isEmpty else {
			return .init(
				completedGames: 0,
				averageTime: 0,
				bestTime: 0,
				averageMistakes: 0,
				totalMistakes: 0,
				cleanGames: 0
			)
		}

		let totalTime: Int = records.reduce(0) { $0 + $1.elapsedSeconds }
		let totalMistakes: Int = records.reduce(0) { $0 + $1.mistakeCount }
		let cleanGames: Int = records.filter { $0.mistakeCount == 0 }.count

		return .init(
			completedGames: records.count,
			averageTime: totalTime / records.count,
			bestTime: records.map(\.elapsedSeconds).min() ?? 0,
			averageMistakes: Double(totalMistakes) / Double(records.count),
			totalMistakes: totalMistakes,
			cleanGames: cleanGames
		)
	}
}
