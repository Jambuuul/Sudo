//
//  StatsInteractor.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

final class StatsInteractor: StatsBusinessLogic {
	// MARK: - Fields
	private let presenter: StatsPresentationLogic

	// MARK: - Lifecycle
	init(presenter: StatsPresentationLogic) {
		self.presenter = presenter
	}

	// MARK: - BusinessLogic
	func loadStart(_ request: Model.Start.Request) {
		presenter.presentStart(.init())
	}
}
