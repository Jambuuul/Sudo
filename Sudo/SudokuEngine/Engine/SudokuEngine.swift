//
//  SudokuEngine.swift
//  SudokuSolver
//
//  Created by Jam on 16.03.2026.
//


public struct SudokuEngine {
	public init() {}
	
	public func validate(board: [[Int]]) -> ValidationResult {
		guard board.count == 9 else { return .invalidSize }
		for row in board where row.count != 9 {
			return .invalidSize
		}
		
		var rowMask = [UInt16](repeating: 0, count: 9)
		var colMask = [UInt16](repeating: 0, count: 9)
		var boxMask = [UInt16](repeating: 0, count: 9)
		
		for r in 0..<9 {
			for c in 0..<9 {
				let v = board[r][c]
				if v < 0 || v > 9 { return .invalidValue }
				if v == 0 { continue }
				
				let bit: UInt16 = 1 << UInt16(v)
				if (rowMask[r] & bit) != 0 { return .rowDuplicate(r) }
				if (colMask[c] & bit) != 0 { return .colDuplicate(c) }
				
				let b = (r / 3) * 3 + (c / 3)
				if (boxMask[b] & bit) != 0 { return .boxDuplicate(b) }
				
				rowMask[r] |= bit
				colMask[c] |= bit
				boxMask[b] |= bit
			}
		}
		
		return .ok
	}
	
	public func solve(board: [[Int]]) throws -> [[Int]] {
		let validation = validate(board: board)
		if validation != .ok { throw SudokuEngineError.invalidBoard(validation) }
		
		let flat = flatten(board)
		guard var solver = SolverCore(board: flat) else {
			throw SudokuEngineError.invalidBoard(validation)
		}
		
		var rng = SystemRandomNumberGenerator()
		if solver.solveOne(randomized: false, rng: &rng, propagation: .full) {
			return unflatten(solver.board)
		}
		
		throw SudokuEngineError.noSolution
	}
	
	public func hasUniqueSolution(board: [[Int]]) -> Bool {
		let validation = validate(board: board)
		if validation != .ok { return false }
		
		let flat = flatten(board)
		return hasUniqueSolution(flat: flat)
	}
	
	public func generate(difficulty: SudokuDifficulty, seed: UInt64? = nil) -> GeneratedPuzzle {
		if let seed = seed {
			var rng = SeededGenerator(seed: seed)
			return generate(difficulty: difficulty, rng: &rng)
		}
		
		var rng = SystemRandomNumberGenerator()
		return generate(difficulty: difficulty, rng: &rng)
	}
	
	// MARK: - Private
	
	private func generate<R: RandomNumberGenerator>(difficulty: SudokuDifficulty, rng: inout R) -> GeneratedPuzzle {
		let target = targetGivensRange(for: difficulty)
		let maxSolutionAttempts = 200
		
		var lastPuzzle: [Int] = []
		var lastSolution: [Int] = []
		
		for _ in 0..<maxSolutionAttempts {
			var solver = SolverCore.empty()
			if !solver.solveOne(randomized: true, rng: &rng, propagation: .full) {
				continue
			}
			
			let solution = solver.board
			var puzzle = solution
			var indices = Array(0..<81)
			indices.shuffle(using: &rng)
			
			var givens = 81
			for idx in indices {
				if givens <= target.max { break }
				
				let backup = puzzle[idx]
				puzzle[idx] = 0
				if hasUniqueSolution(flat: puzzle) {
					givens -= 1
				} else {
					puzzle[idx] = backup
				}
			}
			
			lastPuzzle = puzzle
			lastSolution = solution
			
			if givens >= target.min && givens <= target.max {
				return GeneratedPuzzle(
					puzzle: unflatten(puzzle),
					solution: unflatten(solution)
				)
			}
		}
		
		if lastSolution.isEmpty {
			var solver = SolverCore.empty()
			_ = solver.solveOne(randomized: true, rng: &rng, propagation: .full)
			lastSolution = solver.board
			lastPuzzle = solver.board
		}
		
		// Fallback: return the last unique puzzle even if outside the target range.
		return GeneratedPuzzle(
			puzzle: unflatten(lastPuzzle),
			solution: unflatten(lastSolution)
		)
	}
	
	private func targetGivensRange(for difficulty: SudokuDifficulty) -> (min: Int, max: Int) {
		switch difficulty {
		case .veryEasy:
			return (min: 42, max: 50)
		case .easy:
			return (min: 36, max: 41)
		case .medium:
			return (min: 32, max: 35)
		case .hard:
			return (min: 28, max: 31)
		case .expert:
			return (min: 24, max: 27)
		case .master:
			return (min: 22, max: 24)
		case .custom:
			return (min: 32, max: 35)
		}
	}
	
	private func hasUniqueSolution(flat: [Int]) -> Bool {
		guard var solver = SolverCore(board: flat) else { return false }
		return solver.countSolutions(limit: 2, propagation: .light) == 1
	}
	
	private func flatten(_ board: [[Int]]) -> [Int] {
		var flat: [Int] = []
		flat.reserveCapacity(81)
		for r in 0..<9 {
			flat.append(contentsOf: board[r])
		}
		return flat
	}
	
	private func unflatten(_ flat: [Int]) -> [[Int]] {
		var board = Array(repeating: Array(repeating: 0, count: 9), count: 9)
		for idx in 0..<81 {
			board[idx / 9][idx % 9] = flat[idx]
		}
		return board
	}
}
