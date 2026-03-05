//
//  Interactor.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//


final class MainMenuInteractor: MainMenuBusinessLogic {
    // MARK: - Fields
	private let presenter: MainMenuPresentationLogic

    // MARK: - Lifecycle
	init(presenter: MainMenuPresentationLogic) {
        self.presenter = presenter
    }

    // MARK: - BusinessLogic
    func loadStart(_ request: Model.Start.Request) {
        presenter.presentStart(Model.Start.Response())
    }
	
	func loadNewGame(_ request: Model.NewGame.Request) {
		presenter.presentNewGame(.init())
	}
}
