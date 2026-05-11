//
//  StatsPresenter.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

import Foundation

final class StatsPresenter: StatsPresentationLogic {
	typealias Model = StatsModel

	// MARK: - Constants
	private enum Const {
		static let titleText: String = "Statistics"
		static let allDifficultyText: String = "All Difficulties"
		static let emptyText: String = "No completed games for this filter."
		static let completedTitle: String = "Completed"
		static let averageTimeTitle: String = "Average Time"
		static let bestTimeTitle: String = "Best Time"
		static let averageMistakesTitle: String = "Avg. Mistakes"
		static let totalMistakesTitle: String = "Total Mistakes"
		static let cleanGamesTitle: String = "Clean Games"
		static let doubleFormat: String = "%.1f"
	}

	weak var view: StatsDisplayLogic?

	// MARK: - PresentationLogic
	func presentStats(_ response: Model.LoadStats.Response) {
		let summary: Model.StatsSummary = response.summary
		let items: [Model.StatItem] = [
			.init(title: Const.completedTitle, value: String(summary.completedGames)),
			.init(title: Const.averageTimeTitle, value: TimeFormatter.makeTimeText(elapsedSeconds: summary.averageTime)),
			.init(title: Const.bestTimeTitle, value: TimeFormatter.makeTimeText(elapsedSeconds: summary.bestTime)),
			.init(title: Const.averageMistakesTitle, value: String(format: Const.doubleFormat, summary.averageMistakes)),
			.init(title: Const.totalMistakesTitle, value: String(summary.totalMistakes)),
			.init(title: Const.cleanGamesTitle, value: String(summary.cleanGames))
		]

		view?.displayStats(
			.init(
				titleText: Const.titleText,
				difficultyText: makeDifficultyText(response.difficulty),
				items: items,
				emptyText: Const.emptyText,
				isEmpty: summary.completedGames == 0
			)
		)
	}

	// MARK: - Private methods
	private func makeDifficultyText(_ difficulty: Model.DifficultyFilter) -> String {
		switch difficulty {
		case .all:
			return Const.allDifficultyText
		case .difficulty(let difficulty):
			return makeDifficultyText(difficulty)
		}
	}

	private func makeDifficultyText(_ difficulty: SudokuDifficulty) -> String {
		switch difficulty {
		case .veryEasy:
			return "Very Easy"
		case .easy:
			return "Easy"
		case .medium:
			return "Medium"
		case .hard:
			return "Hard"
		case .expert:
			return "Expert"
		case .master:
			return "Master"
		case .custom:
			return "Custom"
		}
	}
}
