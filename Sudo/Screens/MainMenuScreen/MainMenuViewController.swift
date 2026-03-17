//
//  ViewController.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//


import UIKit

final class MainMenuViewController: UIViewController {
	typealias Model = MainMenuModel
	
    // MARK: - Constants
    private enum Const {
        static let fatalError: String = "init(coder:) has not been implemented"
		
		//button
		static let buttonHorizontal: CGFloat = 40
		static let buttonDistance: CGFloat = 20
		static let buttonsBottomInset: CGFloat = 24
		static let buttonCornerRadius: CGFloat = 12
		static let buttonHeight: CGFloat = 70
		static let buttonAlpha: CGFloat = 0.8
		static let buttonFontSize: CGFloat = 24
		static let newGameCenterYOffset: CGFloat = 10

		//difficulty
		static let difficultyTitle: String = "Select difficulty"
		static let difficultyVeryEasyTitle: String = "Very Easy"
		static let difficultyEasyTitle: String = "Easy"
		static let difficultyMediumTitle: String = "Medium"
		static let difficultyHardTitle: String = "Hard"
		static let difficultyExpertTitle: String = "Expert"
		static let difficultyMasterTitle: String = "Master"
		static let difficultyCancelTitle: String = "Cancel"

		static let rulesLink: String = "https://sudoku.com/sudoku-rules"
		static let titleText: String = "Sudo."
		static let titleFontSize: CGFloat = 48
		static let titleBottomSpacing: CGFloat = 50
		static let newGameTitle: String = "New Game"
		static let howToPlayTitle: String = "How to Play"
		//TODO: fonts into consts
    }

    // MARK: - Fields
    private let interactor: MainMenuBusinessLogic
	
	//buttons
	private let newGameButton: UIButton = UIButton(type: .system)
	private let showRulesButton: UIButton = UIButton(type: .system)
	
	//labels
	private let titleLabel: UILabel = UILabel()


    // MARK: - LifeCycle
    init(
        interactor: MainMenuBusinessLogic
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
		view.backgroundColor = .systemBackground
    }

    // MARK: - Setup
	private func configureUI() {
		configureNewGameButton()
		configureTitleLabel()
		configureRulesButton()
    }
	
	private func configureNewGameButton() {
		view.addSubview(newGameButton)
		
		//design
		newGameButton.backgroundColor = .systemIndigo.withAlphaComponent(Const.buttonAlpha)
		newGameButton.layer.cornerRadius = Const.buttonCornerRadius
		
		//title
		newGameButton.setTitle(Const.newGameTitle, for: .normal)
		newGameButton.titleLabel?.font = .systemFont(ofSize: Const.buttonFontSize, weight: .semibold)
		newGameButton.titleLabel?.textAlignment = .center
		newGameButton.titleLabel?.tintColor = .white
		
		newGameButton.addTarget(self, action: #selector(newGameButtonPressed), for: .touchUpInside)
		
		
		//constraints
		newGameButton.pinCenterY(to: view, Const.newGameCenterYOffset)
		newGameButton.pinLeft(to: view, Const.buttonHorizontal)
		newGameButton.pinRight(to: view, Const.buttonHorizontal)
		newGameButton.setHeight(Const.buttonHeight)
	}
	
	private func configureTitleLabel() {
		view.addSubview(titleLabel)
		titleLabel.text = Const.titleText
		titleLabel.font = .systemFont(ofSize: Const.titleFontSize, weight: .semibold)
		titleLabel.textAlignment = .center
		
		// constraints
		titleLabel.pinLeft(to: view, Const.buttonHorizontal)
		titleLabel.pinRight(to: view, Const.buttonHorizontal)
		titleLabel.pinBottom(to: newGameButton.topAnchor, Const.titleBottomSpacing)
	}
	
	private func configureRulesButton() {
		view.addSubview(showRulesButton)
		
		//design
		showRulesButton.backgroundColor = .systemIndigo.withAlphaComponent(Const.buttonAlpha)
		showRulesButton.layer.cornerRadius = Const.buttonCornerRadius
		
		//title
		showRulesButton.setTitle(Const.howToPlayTitle, for: .normal)
		showRulesButton.titleLabel?.font = .systemFont(ofSize: Const.buttonFontSize, weight: .semibold)
		showRulesButton.titleLabel?.textAlignment = .center
		showRulesButton.titleLabel?.tintColor = .white
		
		showRulesButton.addTarget(self, action: #selector(rulesButtonPressed), for: .touchUpInside)
		
		
		//constraints
		showRulesButton.pinTop(to: newGameButton.bottomAnchor, Const.buttonDistance)
		showRulesButton.pinLeft(to: view, Const.buttonHorizontal)
		showRulesButton.pinRight(to: view, Const.buttonHorizontal)
		showRulesButton.setHeight(Const.buttonHeight)
		showRulesButton.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, Const.buttonsBottomInset, .lsOE)
	}
	

    // MARK: - Actions
    @objc
	private func newGameButtonPressed() {
		presentDifficultyPicker()
    }
	
	@objc
	private func rulesButtonPressed() {
		guard let url = URL(string: Const.rulesLink) else {
			return
		}
		let vc = HowToPlayViewController(url: url)
		navigationController?.pushViewController(vc, animated: true)
	}


	// MARK: - Private methods
	private func presentDifficultyPicker() {
		let alert: UIAlertController = UIAlertController(
			title: Const.difficultyTitle,
			message: nil,
			preferredStyle: .actionSheet
		)
		
		let veryEasyAction: UIAlertAction = makeDifficultyAction(
			title: Const.difficultyVeryEasyTitle,
			difficulty: .veryEasy
		)
		let easyAction: UIAlertAction = makeDifficultyAction(
			title: Const.difficultyEasyTitle,
			difficulty: .easy
		)
		let mediumAction: UIAlertAction = makeDifficultyAction(
			title: Const.difficultyMediumTitle,
			difficulty: .medium
		)
		let hardAction: UIAlertAction = makeDifficultyAction(
			title: Const.difficultyHardTitle,
			difficulty: .hard
		)
		let expertAction: UIAlertAction = makeDifficultyAction(
			title: Const.difficultyExpertTitle,
			difficulty: .expert
		)
		let masterAction: UIAlertAction = makeDifficultyAction(
			title: Const.difficultyMasterTitle,
			difficulty: .master
		)
		let cancelAction: UIAlertAction = UIAlertAction(
			title: Const.difficultyCancelTitle,
			style: .cancel
		)
		
		alert.addAction(veryEasyAction)
		alert.addAction(easyAction)
		alert.addAction(mediumAction)
		alert.addAction(hardAction)
		alert.addAction(expertAction)
		alert.addAction(masterAction)
		alert.addAction(cancelAction)
		
		if let popover = alert.popoverPresentationController {
			popover.sourceView = newGameButton
			popover.sourceRect = newGameButton.bounds
		}
		
		present(alert, animated: true)
	}

	private func makeDifficultyAction(
		title: String,
		difficulty: SudokuDifficulty
	) -> UIAlertAction {
		return UIAlertAction(title: title, style: .default) { [weak self] _ in
			self?.interactor.loadNewGame(.init(difficulty: difficulty))
		}
	}
}
