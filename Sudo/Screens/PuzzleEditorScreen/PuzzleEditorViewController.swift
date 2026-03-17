//
//  PuzzleEditorViewController.swift
//  Sudo
//
//  Created by Jam on 17.03.2026.
//

import UIKit

final class PuzzleEditorViewController: UIViewController {
	typealias Model = PuzzleEditorModel

	// MARK: - Constants
	private enum Const {
		static let fatalError: String = "init(coder:) has not been implemented"
		static let boardSize: Int = SudokuBoard.sideLength
		static let horizontalInset: CGFloat = 20
		static let topInset: CGFloat = 16
		static let titleToStatusSpacing: CGFloat = 6
		static let statusToBoardSpacing: CGFloat = 12
		static let boardToControlsSpacing: CGFloat = 12
		static let controlsToActionsSpacing: CGFloat = 12
		static let bottomInset: CGFloat = 16

		static let titleFontSize: CGFloat = 28
		static let statusFontSize: CGFloat = 14
		static let digitButtonFontSize: CGFloat = 20
		static let actionButtonFontSize: CGFloat = 16

		static let boardCornerRadius: CGFloat = 5
		static let boardSpacing: CGFloat = 0

		static let controlGridRows: Int = 3
		static let controlGridColumns: Int = 3
		static let controlGridSpacing: CGFloat = 10
		static let controlButtonHeight: CGFloat = 46
		static let controlButtonCornerRadius: CGFloat = 12
		static let controlDisabledAlpha: CGFloat = 0.45
		static let controlEnabledAlpha: CGFloat = 1
		static let controlsGridHeight: CGFloat =
		(controlButtonHeight * CGFloat(controlGridRows)) +
		(controlGridSpacing * CGFloat(controlGridRows - 1))

		static let actionButtonHeight: CGFloat = 44
		static let actionButtonCornerRadius: CGFloat = 12
		static let actionBarSpacing: CGFloat = 10

		static let saveTitle: String = "Save"
		static let playTitle: String = "Play"
		static let moreIconName: String = "ellipsis"
		static let validateTitle: String = "Validate"
		static let shareTitle: String = "Share"
		static let importTitle: String = "Import"
		static let clearTitle: String = "Clear Cell"
		static let cancelTitle: String = "Cancel"
		static let okTitle: String = "OK"
		static let importAlertTitle: String = "Import Puzzle"
		static let importPlaceholder: String = "Paste code"
		static let importActionTitle: String = "Import"
		static let copyTitle: String = "Copy"
	}

	// MARK: - Fields
	private let interactor: PuzzleEditorBusinessLogic
	private var cellViewModels: [BoardModel.CellViewModel] = []
	private var digitButtons: [UIButton] = []
	private var hasSelection: Bool = false

	// MARK: - Views
	private let titleLabel: UILabel = UILabel()
	private let statusLabel: UILabel = UILabel()
	private let boardContainerView: UIView = UIView()
	private let controlsStackView: UIStackView = UIStackView()

	private let saveButton: UIButton = UIButton(type: .system)
	private let playButton: UIButton = UIButton(type: .system)
	private let moreButton: UIButton = UIButton(type: .system)
	private let actionBar: UIStackView = UIStackView()

	private lazy var boardCollectionView: UICollectionView = {
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.minimumLineSpacing = Const.boardSpacing
		layout.minimumInteritemSpacing = Const.boardSpacing
		layout.sectionInset = .zero

		let collectionView: UICollectionView = UICollectionView(
			frame: .zero,
			collectionViewLayout: layout
		)
		collectionView.backgroundColor = .clear
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.isScrollEnabled = false
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(
			BoardCollectionViewCell.self,
			forCellWithReuseIdentifier: BoardCollectionViewCell.reuseIdentifier
		)
		return collectionView
	}()

	// MARK: - Lifecycle
	init(interactor: PuzzleEditorBusinessLogic) {
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
		configureStatusLabel()
		configureBoard()
		configureControls()
		configureActionBar()
	}

	private func configureTitleLabel() {
		view.addSubview(titleLabel)
		titleLabel.textAlignment = .center
		titleLabel.font = .systemFont(ofSize: Const.titleFontSize, weight: .bold)

		titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Const.topInset)
		titleLabel.pinLeft(to: view, Const.horizontalInset)
		titleLabel.pinRight(to: view, Const.horizontalInset)
	}

	private func configureStatusLabel() {
		view.addSubview(statusLabel)
		statusLabel.textAlignment = .center
		statusLabel.numberOfLines = .zero
		statusLabel.font = .systemFont(ofSize: Const.statusFontSize, weight: .regular)
		statusLabel.textColor = .secondaryLabel

		statusLabel.pinTop(to: titleLabel.bottomAnchor, Const.titleToStatusSpacing)
		statusLabel.pinLeft(to: view, Const.horizontalInset)
		statusLabel.pinRight(to: view, Const.horizontalInset)
	}

	private func configureBoard() {
		view.addSubview(boardContainerView)
		boardContainerView.addSubview(boardCollectionView)

		boardContainerView.backgroundColor = .secondarySystemBackground
		boardContainerView.layer.cornerRadius = Const.boardCornerRadius
		boardContainerView.clipsToBounds = true

		boardContainerView.pinTop(to: statusLabel.bottomAnchor, Const.statusToBoardSpacing)
		boardContainerView.pinLeft(to: view, Const.horizontalInset)
		boardContainerView.pinRight(to: view, Const.horizontalInset)
		boardContainerView.pinHeight(to: boardContainerView.widthAnchor)

		boardCollectionView.pin(to: boardContainerView)
	}

	private func configureControls() {
		view.addSubview(controlsStackView)
		controlsStackView.axis = .vertical
		controlsStackView.alignment = .fill
		controlsStackView.distribution = .fillEqually
		controlsStackView.spacing = Const.controlGridSpacing

		controlsStackView.pinTop(to: boardContainerView.bottomAnchor, Const.boardToControlsSpacing)
		controlsStackView.pinLeft(to: view, Const.horizontalInset)
		controlsStackView.pinRight(to: view, Const.horizontalInset)
		controlsStackView.setHeight(Const.controlsGridHeight)

		configureDigitButtons()
	}

	private func configureDigitButtons() {
		let digits: [Int] = Array(SudokuBoard.digits)

		for row in 0..<Const.controlGridRows {
			let rowStackView: UIStackView = UIStackView()
			rowStackView.axis = .horizontal
			rowStackView.alignment = .fill
			rowStackView.distribution = .fillEqually
			rowStackView.spacing = Const.controlGridSpacing

			for column in 0..<Const.controlGridColumns {
				let digitIndex: Int = (row * Const.controlGridColumns) + column
				let digitButton: UIButton = makeDigitButton(digit: digits[digitIndex])
				rowStackView.addArrangedSubview(digitButton)
				digitButtons.append(digitButton)
			}

			controlsStackView.addArrangedSubview(rowStackView)
		}
	}

	private func configureActionBar() {
		view.addSubview(actionBar)
		actionBar.axis = .horizontal
		actionBar.alignment = .fill
		actionBar.distribution = .fillEqually
		actionBar.spacing = Const.actionBarSpacing

		actionBar.pinTop(to: controlsStackView.bottomAnchor, Const.controlsToActionsSpacing)
		actionBar.pinLeft(to: view, Const.horizontalInset)
		actionBar.pinRight(to: view, Const.horizontalInset)
		actionBar.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, Const.bottomInset, .lsOE)

		configureActionButton(saveButton, title: Const.saveTitle, selector: #selector(saveButtonPressed))
		configureActionButton(playButton, title: Const.playTitle, selector: #selector(playButtonPressed))
		configureMoreButton()

		actionBar.addArrangedSubview(saveButton)
		actionBar.addArrangedSubview(playButton)
		actionBar.addArrangedSubview(moreButton)

		for view in actionBar.arrangedSubviews {
			view.setHeight(Const.actionButtonHeight)
		}
	}

	private func configureActionButton(_ button: UIButton, title: String, selector: Selector) {
		button.backgroundColor = .systemIndigo.withAlphaComponent(0.85)
		button.layer.cornerRadius = Const.actionButtonCornerRadius
		button.setTitle(title, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: Const.actionButtonFontSize, weight: .semibold)
		button.setTitleColor(.white, for: .normal)
		button.addTarget(self, action: selector, for: .touchUpInside)
	}

	private func configureMoreButton() {
		moreButton.backgroundColor = .tertiarySystemBackground
		moreButton.layer.cornerRadius = Const.actionButtonCornerRadius
		let config: UIImage.SymbolConfiguration = UIImage.SymbolConfiguration(
			pointSize: Const.actionButtonFontSize,
			weight: .semibold
		)
		let image: UIImage? = UIImage(systemName: Const.moreIconName, withConfiguration: config)
		moreButton.setImage(image, for: .normal)
		moreButton.tintColor = .label
		moreButton.addTarget(self, action: #selector(moreButtonPressed), for: .touchUpInside)
	}

	private func makeDigitButton(digit: Int) -> UIButton {
		let button: UIButton = UIButton(type: .system)
		button.tag = digit
		button.backgroundColor = .systemIndigo.withAlphaComponent(0.85)
		button.layer.cornerRadius = Const.controlButtonCornerRadius
		button.setTitle(String(digit), for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: Const.digitButtonFontSize, weight: .semibold)
		button.setTitleColor(.white, for: .normal)
		button.setTitleColor(.white.withAlphaComponent(0.7), for: .disabled)
		button.setHeight(Const.controlButtonHeight)
		button.addTarget(self, action: #selector(digitButtonPressed(_:)), for: .touchUpInside)
		return button
	}

	// MARK: - Actions
	@objc
	private func digitButtonPressed(_ sender: UIButton) {
		interactor.inputDigit(.init(digit: sender.tag))
	}

	@objc
	private func saveButtonPressed() {
		interactor.savePuzzle(.init())
	}

	@objc
	private func playButtonPressed() {
		interactor.playPuzzle(.init())
	}

	@objc
	private func moreButtonPressed() {
		let sheet: UIAlertController = UIAlertController(
			title: nil,
			message: nil,
			preferredStyle: .actionSheet
		)

		let validateAction: UIAlertAction = UIAlertAction(
			title: Const.validateTitle,
			style: .default
		) { [weak self] _ in
			self?.interactor.validatePuzzle(.init())
		}

		let shareAction: UIAlertAction = UIAlertAction(
			title: Const.shareTitle,
			style: .default
		) { [weak self] _ in
			self?.interactor.sharePuzzle(.init())
		}

		let importAction: UIAlertAction = UIAlertAction(
			title: Const.importTitle,
			style: .default
		) { [weak self] _ in
			self?.presentImportPrompt()
		}

		let clearAction: UIAlertAction = UIAlertAction(
			title: Const.clearTitle,
			style: .default
		) { [weak self] _ in
			self?.interactor.clearCell(.init())
		}
		clearAction.isEnabled = hasSelection

		let cancelAction: UIAlertAction = UIAlertAction(
			title: Const.cancelTitle,
			style: .cancel
		)

		sheet.addAction(validateAction)
		sheet.addAction(shareAction)
		sheet.addAction(importAction)
		sheet.addAction(clearAction)
		sheet.addAction(cancelAction)

		if let popover = sheet.popoverPresentationController {
			popover.sourceView = moreButton
			popover.sourceRect = moreButton.bounds
		}

		present(sheet, animated: true)
	}

	// MARK: - Private methods
	private func applyBoardViewModel(_ viewModel: Model.EditorViewModel) {
		titleLabel.text = viewModel.titleText
		statusLabel.text = viewModel.statusText
		hasSelection = viewModel.hasSelection
		cellViewModels = viewModel.cells.map { cell in
			BoardModel.CellViewModel(
				valueText: cell.valueText,
				isGiven: false,
				isSelected: cell.isSelected,
				isIncorrect: false,
				isMatchingSelectedValue: false,
				isInDuplicateRowOrColumn: false
			)
		}
		boardCollectionView.reloadData()
		updateControlsState(hasSelection: viewModel.hasSelection)
	}

	private func updateControlsState(hasSelection: Bool) {
		let alpha: CGFloat = hasSelection ? Const.controlEnabledAlpha : Const.controlDisabledAlpha

		for button in digitButtons {
			button.isEnabled = hasSelection
			button.alpha = alpha
		}
	}

	private func presentImportPrompt() {
		let alert: UIAlertController = UIAlertController(
			title: Const.importAlertTitle,
			message: nil,
			preferredStyle: .alert
		)
		alert.addTextField { textField in
			textField.placeholder = Const.importPlaceholder
		}
		alert.addAction(UIAlertAction(title: Const.importActionTitle, style: .default) { [weak self] _ in
			let code: String = alert.textFields?.first?.text ?? ""
			self?.interactor.importPuzzle(.init(code: code))
		})
		alert.addAction(UIAlertAction(title: Const.okTitle, style: .cancel))
		present(alert, animated: true)
	}

	private func showAlert(title: String, message: String) {
		let alert: UIAlertController = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: Const.okTitle, style: .default))
		present(alert, animated: true)
	}
}

// MARK: - PuzzleEditorDisplayLogic
extension PuzzleEditorViewController: PuzzleEditorDisplayLogic {
	func displayStart(_ viewModel: Model.Start.ViewModel) {
		applyBoardViewModel(viewModel.board)
	}

	func displayBoardChanged(_ viewModel: Model.BoardChanged.ViewModel) {
		applyBoardViewModel(viewModel.board)
	}

	func displayValidate(_ viewModel: Model.Validate.ViewModel) {
		showAlert(title: viewModel.title, message: viewModel.message)
	}

	func displaySave(_ viewModel: Model.Save.ViewModel) {
		showAlert(title: viewModel.title, message: viewModel.message)
	}

	func displayShare(_ viewModel: Model.Share.ViewModel) {
		let alert: UIAlertController = UIAlertController(
			title: viewModel.title,
			message: viewModel.message,
			preferredStyle: .alert
		)
		alert.addTextField { textField in
			textField.text = viewModel.code
			textField.isUserInteractionEnabled = false
		}
		alert.addAction(UIAlertAction(title: Const.copyTitle, style: .default) { _ in
			if !viewModel.code.isEmpty {
				UIPasteboard.general.string = viewModel.code
			}
		})
		alert.addAction(UIAlertAction(title: Const.okTitle, style: .cancel))
		present(alert, animated: true)
	}

	func displayImport(_ viewModel: Model.Import.ViewModel) {
		showAlert(title: viewModel.title, message: viewModel.message)
	}
}

// MARK: - UICollectionViewDataSource
extension PuzzleEditorViewController: UICollectionViewDataSource {
	func collectionView(
		_ collectionView: UICollectionView,
		numberOfItemsInSection section: Int
	) -> Int {
		cellViewModels.count
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		guard
			let cell: BoardCollectionViewCell = collectionView.dequeueReusableCell(
				withReuseIdentifier: BoardCollectionViewCell.reuseIdentifier,
				for: indexPath
			) as? BoardCollectionViewCell
		else {
			return UICollectionViewCell()
		}

		let viewModel: BoardModel.CellViewModel = cellViewModels[indexPath.item]
		cell.configure(with: viewModel, index: indexPath.item, boardSize: Const.boardSize)
		return cell
	}
}

// MARK: - UICollectionViewDelegate
extension PuzzleEditorViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		interactor.selectCell(.init(index: indexPath.item))
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PuzzleEditorViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
		let side: CGFloat = collectionView.bounds.width / CGFloat(Const.boardSize)
		return CGSize(width: side, height: side)
	}
}
