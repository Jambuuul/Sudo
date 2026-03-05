//
//  BoardViewController.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//

import UIKit

final class BoardViewController: UIViewController {
    typealias Model = BoardModel

	// MARK: - Constants
	private enum Const {
		static let fatalError: String = "init(coder:) has not been implemented"

        static let boardSize: Int = SudokuBoard.sideLength
        static let horizontalInset: CGFloat = 20
        static let topInset: CGFloat = 16
        static let titleToStatusSpacing: CGFloat = 8
        static let statusToBoardSpacing: CGFloat = 18
        static let boardToControlsSpacing: CGFloat = 16
        static let controlsToClearSpacing: CGFloat = 12
        static let bottomInset: CGFloat = 16

        static let boardCornerRadius: CGFloat = 16
        static let boardSpacing: CGFloat = 0

        static let titleFontSize: CGFloat = 34
        static let statusFontSize: CGFloat = 16
        static let digitButtonFontSize: CGFloat = 22
        static let clearButtonFontSize: CGFloat = 18

        static let controlGridRows: Int = 3
        static let controlGridColumns: Int = 3
        static let controlGridSpacing: CGFloat = 10
        static let controlButtonHeight: CGFloat = 52
        static let controlButtonCornerRadius: CGFloat = 12
        static let controlDisabledAlpha: CGFloat = 0.45
        static let controlEnabledAlpha: CGFloat = 1
        static let controlsGridHeight: CGFloat =
            (controlButtonHeight * CGFloat(controlGridRows)) +
            (controlGridSpacing * CGFloat(controlGridRows - 1))

        static let clearButtonHeight: CGFloat = 48
        static let clearButtonCornerRadius: CGFloat = 12
        static let clearButtonTitle: String = "Clear Cell"

        static let solvedStatusColor: UIColor = .systemGreen
        static let defaultStatusColor: UIColor = .secondaryLabel
    }
	
	// MARK: - Fields
	private let interactor: BoardBusinessLogic
    private var cellViewModels: [Model.CellViewModel] = []
    private var digitButtons: [UIButton] = []

    // MARK: - Views
    private let titleLabel: UILabel = UILabel()
    private let statusLabel: UILabel = UILabel()
    private let boardContainerView: UIView = UIView()
    private let controlsStackView: UIStackView = UIStackView()
    private let clearButton: UIButton = UIButton(type: .system)

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
	
	// MARK: - LifeCycle
	init(
		interactor: BoardBusinessLogic
	) {
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
        configureClearButton()
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
        statusLabel.textColor = Const.defaultStatusColor

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

    private func configureClearButton() {
        view.addSubview(clearButton)

        clearButton.backgroundColor = .tertiarySystemBackground
        clearButton.layer.cornerRadius = Const.clearButtonCornerRadius
        clearButton.setTitle(Const.clearButtonTitle, for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: Const.clearButtonFontSize, weight: .semibold)
        clearButton.setTitleColor(.label, for: .normal)
        clearButton.setTitleColor(.secondaryLabel, for: .disabled)
        clearButton.addTarget(self, action: #selector(clearButtonPressed), for: .touchUpInside)

        clearButton.pinTop(to: controlsStackView.bottomAnchor, Const.controlsToClearSpacing)
        clearButton.pinLeft(to: view, Const.horizontalInset)
        clearButton.pinRight(to: view, Const.horizontalInset)
        clearButton.setHeight(Const.clearButtonHeight)
        clearButton.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, Const.bottomInset, .lsOE)

        updateControlsState(hasSelection: false, isSolved: false)
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
    private func clearButtonPressed() {
        interactor.clearCell(.init())
    }

    // MARK: - Private methods
    private func applyBoardViewModel(_ viewModel: Model.BoardViewModel) {
        titleLabel.text = viewModel.titleText
        statusLabel.text = viewModel.statusText
        statusLabel.textColor = viewModel.isSolved ? Const.solvedStatusColor : Const.defaultStatusColor
        cellViewModels = viewModel.cells
        boardCollectionView.reloadData()
        updateControlsState(hasSelection: viewModel.hasSelection, isSolved: viewModel.isSolved)
    }

    private func updateControlsState(hasSelection: Bool, isSolved: Bool) {
        let controlsEnabled: Bool = hasSelection && !isSolved
        let alpha: CGFloat = controlsEnabled ? Const.controlEnabledAlpha : Const.controlDisabledAlpha

        for button in digitButtons {
            button.isEnabled = controlsEnabled
            button.alpha = alpha
        }

        clearButton.isEnabled = controlsEnabled
        clearButton.alpha = alpha
    }
}

// MARK: - BoardDisplayLogic
extension BoardViewController: BoardDisplayLogic {
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        applyBoardViewModel(viewModel.board)
    }

    func displayBoardChanged(_ viewModel: Model.BoardChanged.ViewModel) {
        applyBoardViewModel(viewModel.board)
    }
}

// MARK: - UICollectionViewDataSource
extension BoardViewController: UICollectionViewDataSource {
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

        let viewModel: Model.CellViewModel = cellViewModels[indexPath.item]
        cell.configure(with: viewModel, index: indexPath.item, boardSize: Const.boardSize)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension BoardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        interactor.selectCell(.init(index: indexPath.item))
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BoardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let side: CGFloat = collectionView.bounds.width / CGFloat(Const.boardSize)
        return CGSize(width: side, height: side)
    }
}
