//
//  PuzzleCodec.swift
//  Sudo
//
//  Created by Jam on 17.03.2026.
//

import Foundation

enum PuzzleCodec {
	private enum Const {
		static let size: Int = 9
		static let expectedLength: Int = 81
	}

	static func encode(grid: [[Int]]) -> String? {
		guard grid.count == Const.size else {
			return nil
		}

		for row in grid where row.count != Const.size {
			return nil
		}

		var result: String = ""
		result.reserveCapacity(Const.expectedLength)
		for row in grid {
			for value in row {
				guard (0...9).contains(value) else {
					return nil
				}
				result.append(String(value))
			}
		}

		return result
	}

	static func decode(_ text: String) -> [[Int]]? {
		let filtered: String = text.filter { $0.isNumber }
		guard filtered.count == Const.expectedLength else {
			return nil
		}

		var values: [Int] = []
		values.reserveCapacity(Const.expectedLength)

		for char in filtered {
			guard let value = char.wholeNumberValue, (0...9).contains(value) else {
				return nil
			}
			values.append(value)
		}

		var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: Const.size), count: Const.size)
		for index in 0..<Const.expectedLength {
			grid[index / Const.size][index % Const.size] = values[index]
		}

		return grid
	}
}
