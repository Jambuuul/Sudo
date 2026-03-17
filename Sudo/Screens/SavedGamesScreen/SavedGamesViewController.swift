//
//  SavedGamesViewController.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

import UIKit

final class SavedGamesViewController: UIViewController {
	typealias Model = SavedGamesModel

	// MARK: - Constants
	private enum Const {
		static let fatalError: String = "init(coder:) has not been implemented"
		static let horizontalInset: CGFloat = 20
		static let topInset: CGFloat = 16
		static let titleFontSize: CGFloat = 28
		static let titleToSegmentSpacing: CGFloat = 12
		static let segmentToTableSpacing: CGFloat = 12
		static let bottomInset: CGFloat = 16
		static let titleText: String = "Saved Games"
		static let startedTitle: String = "Started"
		static let customTitle: String = "Custom"
		static let createPuzzleTitle: String = "Create Puzzle"
		static let createPuzzleSubtitle: String = "Import or create a new puzzle"
		static let customPuzzleTitle: String = "Custom Puzzle"
		static let emptyText: String = "No saved games yet."
		static let emptyCustomText: String = "No custom puzzles yet."
		static let cellIdentifier: String = "SavedGameCell"
		static let rowHeight: CGFloat = 64
	}

	// MARK: - Fields
	private let interactor: SavedGamesBusinessLogic
	private var games: [SavedGame] = []
	private var puzzles: [UserPuzzle] = []
	private var selectedSegmentIndex: Int = 0

	// MARK: - Views
	private let titleLabel: UILabel = UILabel()
	private let segmentedControl: UISegmentedControl = UISegmentedControl(
		items: [Const.startedTitle, Const.customTitle]
	)
	private let tableView: UITableView = UITableView(frame: .zero, style: .plain)
	private let emptyLabel: UILabel = UILabel()

	// MARK: - Lifecycle
	init(interactor: SavedGamesBusinessLogic) {
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
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadGames()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		loadGames()
	}

	// MARK: - Setup
	private func configureUI() {
		view.backgroundColor = .systemBackground
		configureTitleLabel()
		configureSegmentedControl()
		configureTableView()
		configureEmptyLabel()
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

	private func configureTableView() {
		view.addSubview(tableView)
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = Const.rowHeight
		tableView.separatorStyle = .singleLine
		tableView.backgroundColor = .clear
		tableView.tableFooterView = UIView()

		tableView.pinTop(to: segmentedControl.bottomAnchor, Const.segmentToTableSpacing)
		tableView.pinLeft(to: view, Const.horizontalInset)
		tableView.pinRight(to: view, Const.horizontalInset)
		tableView.pinBottom(to: view.bottomAnchor, Const.bottomInset)
	}

	private func configureSegmentedControl() {
		view.addSubview(segmentedControl)
		segmentedControl.selectedSegmentIndex = selectedSegmentIndex
		segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
		segmentedControl.pinTop(to: titleLabel.bottomAnchor, Const.titleToSegmentSpacing)
		segmentedControl.pinLeft(to: view, Const.horizontalInset)
		segmentedControl.pinRight(to: view, Const.horizontalInset)
	}

	private func configureEmptyLabel() {
		view.addSubview(emptyLabel)
		emptyLabel.text = Const.emptyText
		emptyLabel.textAlignment = .center
		emptyLabel.textColor = .secondaryLabel
		emptyLabel.font = .systemFont(ofSize: 16, weight: .regular)

		emptyLabel.pinCenterX(to: view)
		emptyLabel.pinCenterY(to: view, -40)
	}


	// MARK: - Private methods
	private func loadGames() {
		games = SavedGameStore.shared.loadAll().sorted { $0.updatedAt > $1.updatedAt }
		puzzles = UserPuzzleStore.shared.loadAll().sorted { $0.updatedAt > $1.updatedAt }
		tableView.reloadData()
		updateEmptyState()
	}

	private func updateEmptyState() {
		let isEmpty: Bool = currentItemsCount() == 0
		emptyLabel.isHidden = !isEmpty
		tableView.isHidden = isEmpty
		if selectedSegmentIndex == 0 {
			emptyLabel.text = Const.emptyText
		} else {
			emptyLabel.text = Const.emptyCustomText
		}
	}

	private func currentItemsCount() -> Int {
		if selectedSegmentIndex == 0 {
			return games.count
		}

		return puzzles.count + 1
	}

	private func isCreateRow(_ indexPath: IndexPath) -> Bool {
		return selectedSegmentIndex == 1 && indexPath.row == puzzles.count
	}

	private func makePuzzleSubtitle(_ puzzle: UserPuzzle) -> String {
		let count: Int = puzzle.puzzle.flatMap { $0 }.filter { $0 != 0 }.count
		return "Givens: \(count)/81"
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

	private func filledCount(for game: SavedGame) -> Int {
		var count: Int = 0
		for row in game.current {
			for value in row where value != 0 {
				count += 1
			}
		}
		return count
	}

	// MARK: - Actions
	@objc
	private func segmentChanged() {
		selectedSegmentIndex = segmentedControl.selectedSegmentIndex
		updateEmptyState()
		tableView.reloadData()
	}
}

// MARK: - UITableViewDataSource
extension SavedGamesViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		currentItemsCount()
	}

	func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		let cell: UITableViewCell = tableView.dequeueReusableCell(
			withIdentifier: Const.cellIdentifier
		) ?? UITableViewCell(style: .subtitle, reuseIdentifier: Const.cellIdentifier)

		if selectedSegmentIndex == 0 {
			let game: SavedGame = games[indexPath.row]
			let difficultyText: String = makeDifficultyText(game.difficulty)
			let timeText: String = TimeFormatter.makeTimeText(elapsedSeconds: game.elapsedSeconds)
			let filledText: String = "\(filledCount(for: game))/81"

			cell.textLabel?.text = "\(difficultyText) • \(timeText)"
			cell.detailTextLabel?.text = "Filled: \(filledText)"
			cell.accessoryType = .disclosureIndicator
		} else if isCreateRow(indexPath) {
			cell.textLabel?.text = Const.createPuzzleTitle
			cell.detailTextLabel?.text = Const.createPuzzleSubtitle
			cell.accessoryType = .disclosureIndicator
		} else {
			let puzzle: UserPuzzle = puzzles[indexPath.row]
			cell.textLabel?.text = Const.customPuzzleTitle
			cell.detailTextLabel?.text = makePuzzleSubtitle(puzzle)
			cell.accessoryType = .disclosureIndicator
		}

		cell.layer.cornerRadius = 4
		cell.backgroundColor = .secondarySystemBackground

		return cell
	}
}

// MARK: - UITableViewDelegate
extension SavedGamesViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if selectedSegmentIndex == 0 {
			let game: SavedGame = games[indexPath.row]
			interactor.loadOpenGame(.init(game: game))
			return
		}

		if isCreateRow(indexPath) {
			let editor: UIViewController = PuzzleEditorAssembly.build(source: .new)
			navigationController?.pushViewController(editor, animated: true)
			return
		}

		let puzzle: UserPuzzle = puzzles[indexPath.row]
		let editor: UIViewController = PuzzleEditorAssembly.build(source: .existing(puzzle))
		navigationController?.pushViewController(editor, animated: true)
	}
}
