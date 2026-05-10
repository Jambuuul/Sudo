//
//  NetworkPuzzle.swift
//  Sudo
//
//  Created by Jam on 09.05.2026.
//

struct NetworkPuzzle: Decodable {
	let difficulty: SudokuDifficulty
	let puzzle: [[Int]]
	let solution: [[Int]]
}

struct NetworkKillerCage: Decodable {
	let id: Int
	let sum: Int
	let cells: [Int]
}

struct NetworkKillerPuzzle: Decodable {
	let difficulty: SudokuDifficulty
	let puzzle: [[Int]]
	let solution: [[Int]]
	let cages: [NetworkKillerCage]
}
