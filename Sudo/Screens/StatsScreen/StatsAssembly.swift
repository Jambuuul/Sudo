//
//  StatsAssembly.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

import UIKit

enum StatsAssembly {
	static func build() -> UIViewController {
		let presenter: StatsPresenter = StatsPresenter()
		let interactor: StatsBusinessLogic = StatsInteractor(presenter: presenter)
		let viewController: StatsViewController = StatsViewController(
			interactor: interactor
		)

		presenter.view = viewController

		return viewController
	}
}
