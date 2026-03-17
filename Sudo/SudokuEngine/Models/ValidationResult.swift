//
//  ValidationResult.swift
//  SudokuSolver
//
//  Created by Jam on 16.03.2026.
//


public enum ValidationResult: Equatable {
	case ok
	case invalidSize
	case invalidValue
	case rowDuplicate(Int)
	case colDuplicate(Int)
	case boxDuplicate(Int)
}