//
//  SeededGenerator.swift
//  SudokuSolver
//
//  Created by Jam on 16.03.2026.
//


internal struct SeededGenerator: RandomNumberGenerator {
	private var state: UInt64
	
	init(seed: UInt64) {
		self.state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
	}
	
	mutating func next() -> UInt64 {
		state = state &* 6364136223846793005 &+ 1
		return state
	}
}