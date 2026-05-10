//
//  BoardStartSource.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

struct KillerCage: Codable, Equatable {
	let id: Int
	let sum: Int
	let cells: [Int]
}

enum BoardStartSource {
	case newGame(difficulty: SudokuDifficulty)
	case savedGame(SavedGame)
	case customPuzzle(puzzle: [[Int]], solution: [[Int]])
	case networkPuzzle(difficulty: SudokuDifficulty, puzzle: [[Int]], solution: [[Int]])
	case killerPuzzle(difficulty: SudokuDifficulty, puzzle: [[Int]], solution: [[Int]], cages: [KillerCage])
}
