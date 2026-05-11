//
//  NetworkPuzzle.swift
//  Sudo
//
//  Created by Jam on 09.05.2026.
//

struct NetworkPuzzle: Decodable {
	let difficulty: SudokuDifficulty
	let sourceDifficulty: SudokuDifficulty?
	let puzzle: [[Int]]
	let solution: [[Int]]
}
