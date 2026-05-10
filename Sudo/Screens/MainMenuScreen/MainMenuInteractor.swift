//
//  Interactor.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//


final class MainMenuInteractor: MainMenuBusinessLogic {
    // MARK: - Fields
	private let presenter: MainMenuPresentationLogic
	private let networkPuzzleService: NetworkPuzzleService
	private var networkTask: Task<Void, Never>?

    // MARK: - Lifecycle
	init(
		presenter: MainMenuPresentationLogic,
		networkPuzzleService: NetworkPuzzleService = NetworkPuzzleService()
	) {
        self.presenter = presenter
		self.networkPuzzleService = networkPuzzleService
    }

    // MARK: - BusinessLogic
    func loadStart(_ request: Model.Start.Request) {
        presenter.presentStart(Model.Start.Response())
    }
	
	func loadNewGame(_ request: Model.NewGame.Request) {
		switch request.source {
		case .local:
			presenter.presentNewGame(
				.init(
					difficulty: request.difficulty,
					puzzle: nil,
					solution: nil,
					cages: nil
				)
			)
		case .network:
			loadNetworkGame(difficulty: request.difficulty)
		case .killerNetwork:
			loadNetworkKillerGame(difficulty: request.difficulty)
		}
	}

	deinit {
		networkTask?.cancel()
	}

	// MARK: - Private methods
	private func loadNetworkGame(difficulty: SudokuDifficulty) {
		networkTask?.cancel()
		presenter.presentNetworkLoading(.init())

		networkTask = Task { [weak self] in
			guard let self else {
				return
			}

			do {
				let puzzle: NetworkPuzzle = try await networkPuzzleService.loadPuzzle(
					difficulty: difficulty
				)

				await MainActor.run {
					presenter.presentNewGame(
						.init(
							difficulty: difficulty,
							puzzle: puzzle.puzzle,
							solution: puzzle.solution,
							cages: nil
						)
					)
				}
			} catch {
				await MainActor.run {
					presenter.presentNetworkFailure(.init())
				}
			}
		}
	}

	private func loadNetworkKillerGame(difficulty: SudokuDifficulty) {
		networkTask?.cancel()
		presenter.presentNetworkLoading(.init())

		networkTask = Task { [weak self] in
			guard let self else {
				return
			}

			do {
				let puzzle: NetworkKillerPuzzle = try await networkPuzzleService.loadKillerPuzzle(
					difficulty: difficulty
				)
				let cages: [KillerCage] = puzzle.cages.map {
					KillerCage(id: $0.id, sum: $0.sum, cells: $0.cells)
				}

				await MainActor.run {
					presenter.presentNewGame(
						.init(
							difficulty: difficulty,
							puzzle: puzzle.puzzle,
							solution: puzzle.solution,
							cages: cages
						)
					)
				}
			} catch {
				await MainActor.run {
					presenter.presentNetworkFailure(.init())
				}
			}
		}
	}
}
