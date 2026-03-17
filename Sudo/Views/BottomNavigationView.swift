//
//  BottomNavigationView.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

import UIKit

final class BottomNavigationView: UIView {
	// MARK: - Constants
	private enum Const {
		static let fatalError: String = "init(coder:) has not been implemented"
		static let height: CGFloat = 64
		static let horizontalInset: CGFloat = 16
		static let verticalInset: CGFloat = 8
		static let cornerRadius: CGFloat = 16
		static let iconSize: CGFloat = 20
		static let enabledAlpha: CGFloat = 1
		static let disabledAlpha: CGFloat = 0.5
		static let backgroundColor: UIColor = .secondarySystemBackground
		static let savedIconName: String = "tray.and.arrow.down"
		static let homeIconName: String = "house"
		static let statsIconName: String = "chart.bar"
	}

	enum Item {
		case saved
		case home
		case stats
	}

	// MARK: - Views
	let savedButton: UIButton = UIButton(type: .system)
	let homeButton: UIButton = UIButton(type: .system)
	let statsButton: UIButton = UIButton(type: .system)
	private let stackView: UIStackView = UIStackView()

	// MARK: - Lifecycle
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureUI()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError(Const.fatalError)
	}

	// MARK: - Public methods
	func setSelected(_ item: Item) {
		switch item {
		case .saved:
			setButtonState(enabled: false, button: savedButton)
			setButtonState(enabled: true, button: homeButton)
			setButtonState(enabled: true, button: statsButton)
		case .home:
			setButtonState(enabled: true, button: savedButton)
			setButtonState(enabled: false, button: homeButton)
			setButtonState(enabled: true, button: statsButton)
		case .stats:
			setButtonState(enabled: true, button: savedButton)
			setButtonState(enabled: true, button: homeButton)
			setButtonState(enabled: false, button: statsButton)
		}
	}

	static func height() -> CGFloat {
		Const.height
	}

	// MARK: - Private methods
	private func configureUI() {
		backgroundColor = Const.backgroundColor
		layer.cornerRadius = Const.cornerRadius

		addSubview(stackView)
		stackView.axis = .horizontal
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		stackView.spacing = 0
		stackView.pinTop(to: self, Const.verticalInset)
		stackView.pinBottom(to: self, Const.verticalInset)
		stackView.pinLeft(to: self, Const.horizontalInset)
		stackView.pinRight(to: self, Const.horizontalInset)

		configureButton(savedButton, systemImageName: Const.savedIconName)
		configureButton(homeButton, systemImageName: Const.homeIconName)
		configureButton(statsButton, systemImageName: Const.statsIconName)

		stackView.addArrangedSubview(savedButton)
		stackView.addArrangedSubview(homeButton)
		stackView.addArrangedSubview(statsButton)

		setSelected(.home)
	}

	private func configureButton(_ button: UIButton, systemImageName: String) {
		let config: UIImage.SymbolConfiguration = UIImage.SymbolConfiguration(
			pointSize: Const.iconSize,
			weight: .semibold
		)
		let image: UIImage? = UIImage(systemName: systemImageName, withConfiguration: config)
		button.setImage(image, for: .normal)
		button.contentHorizontalAlignment = .center
		button.setTitleColor(.label, for: .normal)
		button.tintColor = .label
	}

	private func setButtonState(enabled: Bool, button: UIButton) {
		button.isEnabled = enabled
		button.alpha = enabled ? Const.enabledAlpha : Const.disabledAlpha
	}
}
