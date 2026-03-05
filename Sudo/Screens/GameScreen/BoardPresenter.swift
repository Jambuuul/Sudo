//
//  Presenter.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//

import Foundation

final class BoardPresenter: BoardPresentationLogic {
    // MARK: - Constants
    private enum Const {
        static let titleText: String = "Sudoku"
        static let solvedStatusText: String = "Puzzle solved."
        static let inProgressStatusText: String = "Select a cell and fill digits 1...9."
    }

    weak var view: BoardDisplayLogic?

    // MARK: - PresentationLogic
    func presentStart(_ response: Model.Start.Response) {
        let boardViewModel: Model.BoardViewModel = makeBoardViewModel(from: response.state)
        view?.displayStart(
            Model.Start.ViewModel(board: boardViewModel)
        )
    }

    func presentBoardChanged(_ response: Model.BoardChanged.Response) {
        let boardViewModel: Model.BoardViewModel = makeBoardViewModel(from: response.state)
        view?.displayBoardChanged(
            Model.BoardChanged.ViewModel(board: boardViewModel)
        )
    }

    // MARK: - Private methods
    private func makeBoardViewModel(from state: Model.GameState) -> Model.BoardViewModel {
        let selectedIndex: Int? = state.selectedIndex
        let selectedValue: Int? = {
            guard
                let selectedIndex,
                state.cells.indices.contains(selectedIndex)
            else {
                return nil
            }

            return state.cells[selectedIndex].value
        }()

        let hasEditableSelection: Bool = {
            guard
                let selectedIndex,
                state.cells.indices.contains(selectedIndex)
            else {
                return false
            }

            return !state.cells[selectedIndex].isGiven
        }()

        let cells: [Model.CellViewModel] = state.cells.enumerated().map { index, cell in
            Model.CellViewModel(
                valueText: cell.value.map(String.init) ?? "",
                isGiven: cell.isGiven,
                isSelected: selectedIndex == index,
                isIncorrect: cell.isIncorrect,
                isMatchingSelectedValue: cell.value != nil && cell.value == selectedValue
            )
        }

        return Model.BoardViewModel(
            titleText: Const.titleText,
            statusText: state.isSolved ? Const.solvedStatusText : Const.inProgressStatusText,
            cells: cells,
            hasSelection: hasEditableSelection,
            isSolved: state.isSolved
        )
    }
}
