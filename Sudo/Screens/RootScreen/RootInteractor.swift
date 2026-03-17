//
//  RootInteractor.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

final class RootInteractor: RootBusinessLogic {
	// MARK: - Fields
	private let presenter: RootPresentationLogic

	// MARK: - Lifecycle
	init(presenter: RootPresentationLogic) {
		self.presenter = presenter
	}

	// MARK: - BusinessLogic
	func loadStart(_ request: Model.Start.Request) {
		presenter.presentStart(.init())
	}
}
