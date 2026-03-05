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
		newGameButton.backgroundColor = .systemIndigo.withAlphaComponent(0.8)
		newGameButton.layer.cornerRadius = 12
		
		//title
		newGameButton.setTitle("New Game", for: .normal)
		newGameButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
		newGameButton.titleLabel?.textAlignment = .center
		newGameButton.titleLabel?.tintColor = .white
		
		newGameButton.addTarget(self, action: #selector(newGameButtonPressed), for: .touchUpInside)
		
		
		//constraints
		newGameButton.pinCenterY(to: view, 10)
		newGameButton.pinLeft(to: view, Const.buttonHorizontal)
		newGameButton.pinRight(to: view, Const.buttonHorizontal)
		newGameButton.setHeight(70)
	}
	
	private func configureTitleLabel() {
		view.addSubview(titleLabel)
		titleLabel.text = "Sudo."
		titleLabel.font = .systemFont(ofSize: 48, weight: .semibold)
		titleLabel.textAlignment = .center
		
		// constraints
		titleLabel.pinLeft(to: view, Const.buttonHorizontal)
		titleLabel.pinRight(to: view, Const.buttonHorizontal)
		titleLabel.pinBottom(to: newGameButton.topAnchor, 50)
	}
	
	private func configureRulesButton() {
		view.addSubview(showRulesButton)
		
		//design
		showRulesButton.backgroundColor = .systemIndigo.withAlphaComponent(0.8)
		showRulesButton.layer.cornerRadius = 12
		
		//title
		showRulesButton.setTitle("How to Play", for: .normal)
		showRulesButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
		showRulesButton.titleLabel?.textAlignment = .center
		showRulesButton.titleLabel?.tintColor = .white
		
		showRulesButton.addTarget(self, action: #selector(newGameButtonPressed), for: .touchUpInside)
		
		
		//constraints
		showRulesButton.pinTop(to: newGameButton.bottomAnchor, Const.buttonDistance)
		showRulesButton.pinLeft(to: view, Const.buttonHorizontal)
		showRulesButton.pinRight(to: view, Const.buttonHorizontal)
		showRulesButton.setHeight(70)
	}
	

    // MARK: - Actions
    @objc
    private func newGameButtonPressed() {
		interactor.loadNewGame(.init())
    }

}
