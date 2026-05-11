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
		static let emptyFontSize: CGFloat = 16
		static let itemTitleFontSize: CGFloat = 14
		static let itemValueFontSize: CGFloat = 22
		static let titleToSegmentSpacing: CGFloat = 12
		static let segmentToFilterSpacing: CGFloat = 12
		static let filterToStackSpacing: CGFloat = 16
		static let stackSpacing: CGFloat = 10
		static let itemHeight: CGFloat = 64
		static let itemCornerRadius: CGFloat = 10
		static let filterHeight: CGFloat = 44
		static let filterCornerRadius: CGFloat = 12
		static let bottomInset: CGFloat = 16
		static let lastDayTitle: String = "24h"
		static let weekTitle: String = "Week"
		static let allTimeTitle: String = "All"
		static let allDifficultiesTitle: String = "All Difficulties"
		static let cancelTitle: String = "Cancel"
	}

	// MARK: - Fields
	private let interactor: StatsBusinessLogic
	private var period: Model.Period = .lastDay
	private var difficulty: Model.DifficultyFilter = .all
	private var items: [Model.StatItem] = []

	// MARK: - Views
	private let titleLabel: UILabel = UILabel()
	private let periodSegmentedControl: UISegmentedControl = UISegmentedControl(
		items: [Const.lastDayTitle, Const.weekTitle, Const.allTimeTitle]
	)
	private let difficultyButton: UIButton = UIButton(type: .system)
	private let stackView: UIStackView = UIStackView()
	private let emptyLabel: UILabel = UILabel()

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
		loadStats()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadStats()
	}

	// MARK: - Setup
	private func configureUI() {
		view.backgroundColor = .systemBackground
		configureTitleLabel()
		configurePeriodSegmentedControl()
		configureDifficultyButton()
		configureStackView()
		configureEmptyLabel()
	}

	private func configureTitleLabel() {
		view.addSubview(titleLabel)
		titleLabel.font = .systemFont(ofSize: Const.titleFontSize, weight: .semibold)
		titleLabel.textAlignment = .center

		titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Const.topInset)
		titleLabel.pinLeft(to: view, Const.horizontalInset)
		titleLabel.pinRight(to: view, Const.horizontalInset)
	}

	private func configurePeriodSegmentedControl() {
		view.addSubview(periodSegmentedControl)
		periodSegmentedControl.selectedSegmentIndex = period.rawValue
		periodSegmentedControl.addTarget(self, action: #selector(periodChanged), for: .valueChanged)

		periodSegmentedControl.pinTop(to: titleLabel.bottomAnchor, Const.titleToSegmentSpacing)
		periodSegmentedControl.pinLeft(to: view, Const.horizontalInset)
		periodSegmentedControl.pinRight(to: view, Const.horizontalInset)
	}

	private func configureDifficultyButton() {
		view.addSubview(difficultyButton)
		difficultyButton.backgroundColor = .tertiarySystemBackground
		difficultyButton.layer.cornerRadius = Const.filterCornerRadius
		difficultyButton.titleLabel?.font = .systemFont(ofSize: Const.itemTitleFontSize, weight: .semibold)
		difficultyButton.setTitleColor(.label, for: .normal)
		difficultyButton.addTarget(self, action: #selector(difficultyButtonPressed), for: .touchUpInside)

		difficultyButton.pinTop(to: periodSegmentedControl.bottomAnchor, Const.segmentToFilterSpacing)
		difficultyButton.pinLeft(to: view, Const.horizontalInset)
		difficultyButton.pinRight(to: view, Const.horizontalInset)
		difficultyButton.setHeight(Const.filterHeight)
	}

	private func configureStackView() {
		view.addSubview(stackView)
		stackView.axis = .vertical
		stackView.alignment = .fill
		stackView.distribution = .fill
		stackView.spacing = Const.stackSpacing

		stackView.pinTop(to: difficultyButton.bottomAnchor, Const.filterToStackSpacing)
		stackView.pinLeft(to: view, Const.horizontalInset)
		stackView.pinRight(to: view, Const.horizontalInset)
		stackView.pinBottom(to: view.bottomAnchor, Const.bottomInset, .lsOE)
	}

	private func configureEmptyLabel() {
		view.addSubview(emptyLabel)
		emptyLabel.font = .systemFont(ofSize: Const.emptyFontSize, weight: .regular)
		emptyLabel.textAlignment = .center
		emptyLabel.textColor = .secondaryLabel
		emptyLabel.numberOfLines = .zero

		emptyLabel.pinLeft(to: view, Const.horizontalInset)
		emptyLabel.pinRight(to: view, Const.horizontalInset)
		emptyLabel.pinCenterY(to: view)
	}

	// MARK: - Actions
	@objc
	private func periodChanged() {
		period = Model.Period(rawValue: periodSegmentedControl.selectedSegmentIndex) ?? .lastDay
		loadStats()
	}

	@objc
	private func difficultyButtonPressed() {
		let alert: UIAlertController = UIAlertController(
			title: Const.allDifficultiesTitle,
			message: nil,
			preferredStyle: .actionSheet
		)

		alert.addAction(makeDifficultyAction(title: Const.allDifficultiesTitle, difficulty: .all))
		for difficulty in makeDifficulties() {
			alert.addAction(
				makeDifficultyAction(
					title: makeDifficultyText(difficulty),
					difficulty: .difficulty(difficulty)
				)
			)
		}
		alert.addAction(UIAlertAction(title: Const.cancelTitle, style: .cancel))

		if let popover = alert.popoverPresentationController {
			popover.sourceView = difficultyButton
			popover.sourceRect = difficultyButton.bounds
		}

		present(alert, animated: true)
	}

	// MARK: - Private methods
	private func loadStats() {
		interactor.loadStats(
			.init(
				period: period,
				difficulty: difficulty
			)
		)
	}

	private func applyViewModel(_ viewModel: Model.LoadStats.ViewModel) {
		titleLabel.text = viewModel.titleText
		difficultyButton.setTitle(viewModel.difficultyText, for: .normal)
		emptyLabel.text = viewModel.emptyText
		emptyLabel.isHidden = !viewModel.isEmpty
		stackView.isHidden = viewModel.isEmpty
		items = viewModel.items
		rebuildStack()
	}

	private func rebuildStack() {
		for view in stackView.arrangedSubviews {
			stackView.removeArrangedSubview(view)
			view.removeFromSuperview()
		}

		for item in items {
			stackView.addArrangedSubview(makeItemView(item))
		}
	}

	private func makeItemView(_ item: Model.StatItem) -> UIView {
		let container: UIView = UIView()
		let titleLabel: UILabel = UILabel()
		let valueLabel: UILabel = UILabel()

		container.backgroundColor = .secondarySystemBackground
		container.layer.cornerRadius = Const.itemCornerRadius
		container.setHeight(Const.itemHeight)

		container.addSubview(titleLabel)
		container.addSubview(valueLabel)

		titleLabel.text = item.title
		titleLabel.font = .systemFont(ofSize: Const.itemTitleFontSize, weight: .regular)
		titleLabel.textColor = .secondaryLabel

		valueLabel.text = item.value
		valueLabel.font = .systemFont(ofSize: Const.itemValueFontSize, weight: .semibold)
		valueLabel.textAlignment = .right

		titleLabel.pinLeft(to: container, Const.horizontalInset)
		titleLabel.pinCenterY(to: container)

		valueLabel.pinRight(to: container, Const.horizontalInset)
		valueLabel.pinCenterY(to: container)
		valueLabel.pinLeft(to: titleLabel.trailingAnchor, Const.stackSpacing, .grOE)

		return container
	}

	private func makeDifficultyAction(
		title: String,
		difficulty: Model.DifficultyFilter
	) -> UIAlertAction {
		UIAlertAction(title: title, style: .default) { [weak self] _ in
			self?.difficulty = difficulty
			self?.loadStats()
		}
	}

	private func makeDifficulties() -> [SudokuDifficulty] {
		[
			.veryEasy,
			.easy,
			.medium,
			.hard,
			.expert,
			.master,
			.custom
		]
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

// MARK: - StatsDisplayLogic
extension StatsViewController: StatsDisplayLogic {
	func displayStats(_ viewModel: Model.LoadStats.ViewModel) {
		applyViewModel(viewModel)
	}
}
