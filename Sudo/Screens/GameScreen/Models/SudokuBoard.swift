//
//  SudokuBoard.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//

import Foundation

struct SudokuPosition: Equatable {
    let row: Int
    let column: Int
}

struct SudokuCell {
    let position: SudokuPosition
    var value: Int?
    let solution: Int
    let isGiven: Bool

    var isCorrect: Bool {
        guard let value else {
            return true
        }

        return value == solution
    }
}

struct SudokuBoard {
    // MARK: - Constants
    private enum Constants {
        static let sideLength: Int = 9
        static let emptyValue: Int = 0
        static let minimumDigit: Int = 1
        static let maximumDigit: Int = 9
    }

    // MARK: - PuzzleTemplate
    public struct PuzzleTemplate {
        let puzzle: [[Int]]
        let solution: [[Int]]
    }

    // MARK: - Static
    static let sideLength: Int = Constants.sideLength
    static let digits: ClosedRange<Int> = Constants.minimumDigit...Constants.maximumDigit

    // MARK: - Fields
    private(set) var cells: [SudokuCell] = []

    // MARK: - Lifecycle
    init() {
        self = Self.makeDefaultBoard()
    }

    init(template: PuzzleTemplate) {
        cells = Self.makeCells(from: template)
    }

    // MARK: - Computed properties
    var cellCount: Int {
        cells.count
    }

    var isSolved: Bool {
        cells.allSatisfy { $0.value == $0.solution }
    }

    // MARK: - Public methods
    func cell(at index: Int) -> SudokuCell? {
        guard cells.indices.contains(index) else {
            return nil
        }

        return cells[index]
    }

    @discardableResult
    mutating func updateValue(_ value: Int?, at index: Int) -> Bool {
        guard cells.indices.contains(index) else {
            return false
        }

        guard !cells[index].isGiven else {
            return false
        }

        if let value {
            guard Self.digits.contains(value) else {
                return false
            }
        }

        cells[index].value = value
        return true
    }

    // MARK: - Private methods
    private static func makeDefaultBoard() -> SudokuBoard {
		SudokuBoard(template: .defaultTemplate)
    }

    private static func makeCells(from template: PuzzleTemplate) -> [SudokuCell] {
        var result: [SudokuCell] = []
        result.reserveCapacity(Constants.sideLength * Constants.sideLength)

        for row in 0..<Constants.sideLength {
            for column in 0..<Constants.sideLength {
                let puzzleValue = template.puzzle[row][column]
                let solutionValue = template.solution[row][column]
                let initialValue: Int? = puzzleValue == Constants.emptyValue ? nil : puzzleValue

                let cell = SudokuCell(
                    position: SudokuPosition(row: row, column: column),
                    value: initialValue,
                    solution: solutionValue,
                    isGiven: puzzleValue != Constants.emptyValue
                )

                result.append(cell)
            }
        }

        return result
    }
}

public extension SudokuBoard.PuzzleTemplate {
    internal static let defaultTemplate: Self = Self(
        puzzle: [
            [5, 3, 0, 0, 7, 0, 0, 0, 0],
            [6, 0, 0, 1, 9, 5, 0, 0, 0],
            [0, 9, 8, 0, 0, 0, 0, 6, 0],
            [8, 0, 0, 0, 6, 0, 0, 0, 3],
            [4, 0, 0, 8, 0, 3, 0, 0, 1],
            [7, 0, 0, 0, 2, 0, 0, 0, 6],
            [0, 6, 0, 0, 0, 0, 2, 8, 0],
            [0, 0, 0, 4, 1, 9, 0, 0, 5],
            [0, 0, 0, 0, 8, 0, 0, 7, 9]
        ],
        solution: [
            [5, 3, 4, 6, 7, 8, 9, 1, 2],
            [6, 7, 2, 1, 9, 5, 3, 4, 8],
            [1, 9, 8, 3, 4, 2, 5, 6, 7],
            [8, 5, 9, 7, 6, 1, 4, 2, 3],
            [4, 2, 6, 8, 5, 3, 7, 9, 1],
            [7, 1, 3, 9, 2, 4, 8, 5, 6],
            [9, 6, 1, 5, 3, 7, 2, 8, 4],
            [2, 8, 7, 4, 1, 9, 6, 3, 5],
            [3, 4, 5, 2, 8, 6, 1, 7, 9]
        ]
    )
}
