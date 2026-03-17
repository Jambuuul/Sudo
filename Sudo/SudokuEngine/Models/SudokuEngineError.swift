//
//  SudokuEngineError.swift
//  SudokuSolver
//
//  Created by Jam on 16.03.2026.
//


public enum SudokuEngineError: Error {
	case invalidBoard(ValidationResult)
	case noSolution
}