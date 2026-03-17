//
//  SolverCore.swift
//  SudokuSolver
//
//  Created by Jam on 16.03.2026.
//

internal struct SolverCore {
	var board: [Int]
	private var candidates: [UInt16]
	private var rowMask: [UInt16]
	private var colMask: [UInt16]
	private var boxMask: [UInt16]
	
	enum PropagationLevel {
		case full
		case light
	}
	
	static let fullMask: UInt16 = 0b1111111110
	static let bitCount: [UInt8] = {
		var table = [UInt8](repeating: 0, count: 1024)
		for i in 1..<1024 {
			table[i] = table[i >> 1] &+ UInt8(i & 1)
		}
		return table
	}()
	
	static let units: [[Int]] = {
		var all: [[Int]] = []
		all.reserveCapacity(27)
		
		for r in 0..<9 {
			var row: [Int] = []
			row.reserveCapacity(9)
			for c in 0..<9 { row.append(r * 9 + c) }
			all.append(row)
		}
		for c in 0..<9 {
			var col: [Int] = []
			col.reserveCapacity(9)
			for r in 0..<9 { col.append(r * 9 + c) }
			all.append(col)
		}
		for br in 0..<3 {
			for bc in 0..<3 {
				var box: [Int] = []
				box.reserveCapacity(9)
				for r in 0..<3 {
					for c in 0..<3 {
						box.append((br * 3 + r) * 9 + (bc * 3 + c))
					}
				}
				all.append(box)
			}
		}
		
		return all
	}()
	
	static func empty() -> SolverCore {
		return SolverCore(board: [Int](repeating: 0, count: 81))!
	}
	
	init?(board: [Int]) {
		guard board.count == 81 else { return nil }
		self.board = board
		self.candidates = [UInt16](repeating: SolverCore.fullMask, count: 81)
		self.rowMask = [UInt16](repeating: 0, count: 9)
		self.colMask = [UInt16](repeating: 0, count: 9)
		self.boxMask = [UInt16](repeating: 0, count: 9)
		
		for idx in 0..<81 {
			let v = board[idx]
			if v < 0 || v > 9 { return nil }
			if v == 0 { continue }
			
			let r = idx / 9
			let c = idx % 9
			let b = (r / 3) * 3 + (c / 3)
			let bit: UInt16 = 1 << UInt16(v)
			
			if (rowMask[r] & bit) != 0 { return nil }
			if (colMask[c] & bit) != 0 { return nil }
			if (boxMask[b] & bit) != 0 { return nil }
			
			rowMask[r] |= bit
			colMask[c] |= bit
			boxMask[b] |= bit
		}
		
		for idx in 0..<81 {
			let v = board[idx]
			if v == 0 {
				let r = idx / 9
				let c = idx % 9
				let b = (r / 3) * 3 + (c / 3)
				let allowed = SolverCore.fullMask & ~(rowMask[r] | colMask[c] | boxMask[b])
				if allowed == 0 { return nil }
				candidates[idx] = allowed
			} else {
				candidates[idx] = 1 << UInt16(v)
			}
		}
	}
	
	mutating func solveOne<R: RandomNumberGenerator>(
		randomized: Bool,
		rng: inout R,
		propagation: PropagationLevel = .full
	) -> Bool {
		if !propagate(level: propagation) { return false }
		if isSolved() { return true }
		
		guard let guess = selectGuessCell() else { return false }
		var digits: [Int] = []
		digits.reserveCapacity(guess.count)
		
		var mask = guess.mask
		while mask != 0 {
			let lsb = mask & (~mask &+ 1)
			let digit = Int(lsb.trailingZeroBitCount)
			digits.append(digit)
			mask &= mask &- 1
		}
		
		if randomized { digits.shuffle(using: &rng) }
		
		for digit in digits {
			var branch = self
			if branch.assign(guess.idx, digit)
				&& branch.solveOne(randomized: randomized, rng: &rng, propagation: propagation) {
				self = branch
				return true
			}
		}
		
		return false
	}
	
	mutating func countSolutions(limit: Int, propagation: PropagationLevel = .light) -> Int {
		var count = 0
		_ = countSolutions(limit: limit, count: &count, propagation: propagation)
		return count
	}
	
	private mutating func countSolutions(
		limit: Int,
		count: inout Int,
		propagation: PropagationLevel
	) -> Bool {
		if !propagate(level: propagation) { return true }
		if isSolved() {
			count += 1
			return count < limit
		}
		
		guard let guess = selectGuessCell() else { return true }
		var mask = guess.mask
		while mask != 0 {
			let lsb = mask & (~mask &+ 1)
			let digit = Int(lsb.trailingZeroBitCount)
			var branch = self
			if branch.assign(guess.idx, digit) {
				if branch.countSolutions(
					limit: limit,
					count: &count,
					propagation: propagation
				) == false { return false }
			}
			mask &= mask &- 1
		}
		
		return true
	}
	
	// MARK: - Crook-style Propagation
	
	private mutating func propagate(level: PropagationLevel) -> Bool {
		while true {
			if !constrainCandidates() { return false }
			if isSolved() { return true }
			
			let naked = applyNakedSingles()
			if !naked.ok { return false }
			if naked.progress { continue }
			
			let hidden = applyHiddenSingles()
			if !hidden.ok { return false }
			if hidden.progress { continue }
			
			if level == .full {
				let preempt = applyPreemptiveSets()
				if !preempt.ok { return false }
				if preempt.progress { continue }
				
				let boxLine = applyBoxLineReduction()
				if !boxLine.ok { return false }
				if boxLine.progress { continue }
			}
			
			break
		}
		
		return true
	}
	
	private mutating func constrainCandidates() -> Bool {
		for idx in 0..<81 {
			let v = board[idx]
			if v != 0 {
				candidates[idx] = 1 << UInt16(v)
				continue
			}
			
			let r = idx / 9
			let c = idx % 9
			let b = (r / 3) * 3 + (c / 3)
			let allowed = SolverCore.fullMask & ~(rowMask[r] | colMask[c] | boxMask[b])
			let newMask = candidates[idx] & allowed
			if newMask == 0 { return false }
			candidates[idx] = newMask
		}
		return true
	}
	
	private mutating func applyNakedSingles() -> (progress: Bool, ok: Bool) {
		var progress = false
		for idx in 0..<81 where board[idx] == 0 {
			let mask = candidates[idx]
			if SolverCore.popCount(mask) == 1 {
				let digit = Int(mask.trailingZeroBitCount)
				if !assign(idx, digit) { return (false, false) }
				progress = true
			}
		}
		return (progress, true)
	}
	
	private mutating func applyHiddenSingles() -> (progress: Bool, ok: Bool) {
		var progress = false
		
		for unit in SolverCore.units {
			var counts = [Int](repeating: 0, count: 10)
			var lastIdx = [Int](repeating: -1, count: 10)
			
			for idx in unit where board[idx] == 0 {
				var mask = candidates[idx]
				while mask != 0 {
					let lsb = mask & (~mask &+ 1)
					let digit = Int(lsb.trailingZeroBitCount)
					counts[digit] += 1
					lastIdx[digit] = idx
					mask &= mask &- 1
				}
			}
			
			for digit in 1...9 where counts[digit] == 1 {
				let idx = lastIdx[digit]
				if idx >= 0 && board[idx] == 0 {
					if !assign(idx, digit) { return (false, false) }
					progress = true
				}
			}
		}
		
		return (progress, true)
	}
	
	private mutating func applyPreemptiveSets() -> (progress: Bool, ok: Bool) {
		var progress = false
		
		for unit in SolverCore.units {
			let cells = unit.filter { board[$0] == 0 }
			let n = cells.count
			if n < 2 { continue }
			
			var cellMasks: [UInt16] = []
			cellMasks.reserveCapacity(n)
			for idx in cells { cellMasks.append(candidates[idx]) }
			
			let maxSubsetSize = 4
			let subsetLimit = 1 << n
			for subset in 1..<subsetLimit {
				let subsetSize = subset.nonzeroBitCount
				if subsetSize < 2 || subsetSize > maxSubsetSize { continue }
				
				var unionMask: UInt16 = 0
				for i in 0..<n where (subset & (1 << i)) != 0 {
					unionMask |= cellMasks[i]
				}
				
				if SolverCore.popCount(unionMask) != subsetSize { continue }
				
				for i in 0..<n where (subset & (1 << i)) == 0 {
					let idx = cells[i]
					let newMask = candidates[idx] & ~unionMask
					if newMask != candidates[idx] {
						if newMask == 0 { return (false, false) }
						candidates[idx] = newMask
						progress = true
					}
				}
			}
		}
		
		return (progress, true)
	}
	
	private mutating func applyBoxLineReduction() -> (progress: Bool, ok: Bool) {
		var progress = false
		
		for br in 0..<3 {
			for bc in 0..<3 {
				let rowBase = br * 3
				let colBase = bc * 3
				
				for digit in 1...9 {
					let bit: UInt16 = 1 << UInt16(digit)
					var rowBits: UInt16 = 0
					var colBits: UInt16 = 0
					
					for r in 0..<3 {
						for c in 0..<3 {
							let rr = rowBase + r
							let cc = colBase + c
							let idx = rr * 9 + cc
							if board[idx] == 0 && (candidates[idx] & bit) != 0 {
								rowBits |= 1 << UInt16(rr)
								colBits |= 1 << UInt16(cc)
							}
						}
					}
					
					if rowBits != 0 && SolverCore.popCount(rowBits) == 1 {
						let r = Int(rowBits.trailingZeroBitCount)
						for c in 0..<9 where c < colBase || c >= colBase + 3 {
							let idx = r * 9 + c
							if board[idx] == 0 && (candidates[idx] & bit) != 0 {
								let newMask = candidates[idx] & ~bit
								if newMask == 0 { return (false, false) }
								candidates[idx] = newMask
								progress = true
							}
						}
					}
					
					if colBits != 0 && SolverCore.popCount(colBits) == 1 {
						let c = Int(colBits.trailingZeroBitCount)
						for r in 0..<9 where r < rowBase || r >= rowBase + 3 {
							let idx = r * 9 + c
							if board[idx] == 0 && (candidates[idx] & bit) != 0 {
								let newMask = candidates[idx] & ~bit
								if newMask == 0 { return (false, false) }
								candidates[idx] = newMask
								progress = true
							}
						}
					}
				}
			}
		}
		
		return (progress, true)
	}
	
	// MARK: - Helpers
	
	private func isSolved() -> Bool {
		return !board.contains(0)
	}
	
	private func selectGuessCell() -> (idx: Int, mask: UInt16, count: Int)? {
		var bestIdx = -1
		var bestMask: UInt16 = 0
		var bestCount = 10
		
		for idx in 0..<81 where board[idx] == 0 {
			let mask = candidates[idx]
			let count = SolverCore.popCount(mask)
			if count < bestCount {
				bestCount = count
				bestIdx = idx
				bestMask = mask
				if count == 2 { break }
			}
		}
		
		if bestIdx == -1 { return nil }
		return (bestIdx, bestMask, bestCount)
	}
	
	private mutating func assign(_ idx: Int, _ digit: Int) -> Bool {
		if board[idx] == digit { return true }
		if board[idx] != 0 { return false }
		
		let r = idx / 9
		let c = idx % 9
		let b = (r / 3) * 3 + (c / 3)
		let bit: UInt16 = 1 << UInt16(digit)
		
		if (rowMask[r] & bit) != 0 { return false }
		if (colMask[c] & bit) != 0 { return false }
		if (boxMask[b] & bit) != 0 { return false }
		
		board[idx] = digit
		candidates[idx] = bit
		rowMask[r] |= bit
		colMask[c] |= bit
		boxMask[b] |= bit
		return true
	}
	
	private static func popCount(_ mask: UInt16) -> Int {
		return Int(bitCount[Int(mask)])
	}
}
