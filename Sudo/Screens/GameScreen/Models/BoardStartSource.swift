//
//  BoardStartSource.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

enum BoardStartSource {
	case newGame(difficulty: SudokuDifficulty)
	case savedGame(SavedGame)
	case customPuzzle(puzzle: [[Int]], solution: [[Int]])
	case networkPuzzle(difficulty: SudokuDifficulty, puzzle: [[Int]], solution: [[Int]])
}
