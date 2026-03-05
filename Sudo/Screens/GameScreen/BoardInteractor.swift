//
//  Interactor.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//


final class BoardInteractor: BoardBusinessLogic {
    // MARK: - Fields
	private let presenter: BoardPresentationLogic
    private var board: SudokuBoard = SudokuBoard()
    private var selectedIndex: Int?

    // MARK: - Lifecycle
	init(presenter: BoardPresentationLogic) {
        self.presenter = presenter
    }

    // MARK: - BusinessLogic
    func loadStart(_ request: Model.Start.Request) {
        presenter.presentStart(
            Model.Start.Response(
                state: makeState()
            )
        )
    }

    func selectCell(_ request: Model.SelectCell.Request) {
        guard (0..<board.cellCount).contains(request.index) else {
            return
        }

        selectedIndex = request.index
        presenter.presentBoardChanged(
            Model.BoardChanged.Response(
                state: makeState()
            )
        )
    }

    func inputDigit(_ request: Model.InputDigit.Request) {
        guard let selectedIndex else {
            return
        }

        guard board.updateValue(request.digit, at: selectedIndex) else {
            return
        }

        presenter.presentBoardChanged(
            Model.BoardChanged.Response(
                state: makeState()
            )
        )
    }

    func clearCell(_ request: Model.ClearCell.Request) {
        guard let selectedIndex else {
            return
        }

        guard board.updateValue(nil, at: selectedIndex) else {
            return
        }

        presenter.presentBoardChanged(
            Model.BoardChanged.Response(
                state: makeState()
            )
        )
    }

    // MARK: - Private methods
    private func makeState() -> Model.GameState {
        let cells: [Model.CellState] = board.cells.map { cell in
            Model.CellState(
                value: cell.value,
                isGiven: cell.isGiven,
                isIncorrect: !cell.isCorrect
            )
        }

        return Model.GameState(
            cells: cells,
            selectedIndex: selectedIndex,
            isSolved: board.isSolved
        )
    }
}
