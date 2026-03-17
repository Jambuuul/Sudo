//
//  RootAssembly.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

import UIKit

enum RootAssembly {
	static func build() -> UIViewController {
		let presenter: RootPresenter = RootPresenter()
		let interactor: RootBusinessLogic = RootInteractor(presenter: presenter)
		let viewController: RootViewController = RootViewController(
			interactor: interactor
		)

		presenter.view = viewController

		return viewController
	}
}
