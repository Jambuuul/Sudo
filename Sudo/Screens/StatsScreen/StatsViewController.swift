//
//  StatsViewController.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

import UIKit

final class StatsViewController: UIViewController {
	typealias Model = StatsModel

	// MARK: - Constants
	private enum Const {
		static let fatalError: String = "init(coder:) has not been implemented"
		static let horizontalInset: CGFloat = 20
		static let topInset: CGFloat = 16
		static let titleFontSize: CGFloat = 28
		static let infoFontSize: CGFloat = 16
		static let titleToInfoSpacing: CGFloat = 12
		static let bottomInset: CGFloat = 16
		static let titleText: String = "Statistics"
		static let infoText: String = "Stats will appear here."
	}

	// MARK: - Fields
	private let interactor: StatsBusinessLogic

	// MARK: - Views
	private let titleLabel: UILabel = UILabel()
	private let infoLabel: UILabel = UILabel()

	// MARK: - Lifecycle
	init(interactor: StatsBusinessLogic) {
		self.interactor = interactor
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError(Const.fatalError)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		configureUI()
		interactor.loadStart(.init())
	}

	// MARK: - Setup
	private func configureUI() {
		view.backgroundColor = .systemBackground
		configureTitleLabel()
		configureInfoLabel()
	}

	private func configureTitleLabel() {
		view.addSubview(titleLabel)
		titleLabel.text = Const.titleText
		titleLabel.font = .systemFont(ofSize: Const.titleFontSize, weight: .semibold)
		titleLabel.textAlignment = .center

		titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Const.topInset)
		titleLabel.pinLeft(to: view, Const.horizontalInset)
		titleLabel.pinRight(to: view, Const.horizontalInset)
	}

	private func configureInfoLabel() {
		view.addSubview(infoLabel)
		infoLabel.text = Const.infoText
		infoLabel.font = .systemFont(ofSize: Const.infoFontSize, weight: .regular)
		infoLabel.textAlignment = .center
		infoLabel.textColor = .secondaryLabel

		infoLabel.pinTop(to: titleLabel.bottomAnchor, Const.titleToInfoSpacing)
		infoLabel.pinLeft(to: view, Const.horizontalInset)
		infoLabel.pinRight(to: view, Const.horizontalInset)
		infoLabel.pinBottom(to: view.bottomAnchor, Const.bottomInset, .lsOE)
	}
}
