//
//  Model.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//


enum BoardModel {
    struct CellState {
        let value: Int?
        let isGiven: Bool
        let isIncorrect: Bool
    }

    struct GameState {
        let cells: [CellState]
        let selectedIndex: Int?
        let isSolved: Bool
    }

    struct CellViewModel {
        let valueText: String
        let isGiven: Bool
        let isSelected: Bool
        let isIncorrect: Bool
        let isMatchingSelectedValue: Bool
    }

    struct BoardViewModel {
        let titleText: String
        let statusText: String
        let cells: [CellViewModel]
        let hasSelection: Bool
        let isSolved: Bool
    }

    enum Start {
        struct Request { }
        struct Response {
            let state: GameState
        }

        struct ViewModel {
            let board: BoardViewModel
        }
    }

    enum BoardChanged {
        struct Response {
            let state: GameState
        }

        struct ViewModel {
            let board: BoardViewModel
        }
    }

    enum SelectCell {
        struct Request {
            let index: Int
        }
    }

    enum InputDigit {
        struct Request {
            let digit: Int
        }
    }

    enum ClearCell {
        struct Request { }
    }

    //    enum Other {
    //        struct Request { }
    //        struct Response { }
    //        struct ViewModel { }
    //    }
}
