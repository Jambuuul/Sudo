//
//  NetworkPuzzleService.swift
//  Sudo
//
//  Created by Jam on 09.05.2026.
//

import Foundation

enum NetworkPuzzleServiceError: Error {
	case invalidURL
	case invalidResponse
	case invalidPuzzle
}

final class NetworkPuzzleService {
	// MARK: - Constants
	private enum Const {
		static let baseURL: String = "http://127.0.0.1:8080/v1/puzzles"
		static let difficultyQueryName: String = "difficulty"
		static let successStatusRange: ClosedRange<Int> = 200...299
		static let sideLength: Int = SudokuBoard.sideLength
	}

	// MARK: - Fields
	private let session: URLSession

	// MARK: - Lifecycle
	init(session: URLSession = .shared) {
		self.session = session
	}

	// MARK: - Public methods
	func loadPuzzle(difficulty: SudokuDifficulty) async throws -> NetworkPuzzle {
		guard var components: URLComponents = URLComponents(string: Const.baseURL) else {
			throw NetworkPuzzleServiceError.invalidURL
		}

		components.queryItems = [
			URLQueryItem(name: Const.difficultyQueryName, value: difficulty.rawValue)
		]

		guard let url: URL = components.url else {
			throw NetworkPuzzleServiceError.invalidURL
		}

		let (data, response) = try await session.data(from: url)
		guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse,
			  Const.successStatusRange.contains(httpResponse.statusCode)
		else {
			throw NetworkPuzzleServiceError.invalidResponse
		}

		let puzzle: NetworkPuzzle = try JSONDecoder().decode(NetworkPuzzle.self, from: data)
		guard puzzle.difficulty == difficulty,
			  puzzle.sourceDifficulty == nil || puzzle.sourceDifficulty == difficulty,
			  isValidPuzzleGrid(puzzle.puzzle, solution: puzzle.solution),
			  isSolvedGrid(puzzle.solution)
		else {
			throw NetworkPuzzleServiceError.invalidPuzzle
		}

		return puzzle
	}

	// MARK: - Private methods
	private func isValidPuzzleGrid(_ puzzle: [[Int]], solution: [[Int]]) -> Bool {
		guard isValidShape(puzzle), isValidShape(solution) else {
			return false
		}

		for row in 0..<Const.sideLength {
			for column in 0..<Const.sideLength {
				let value: Int = puzzle[row][column]
				guard (0...9).contains(value) else {
					return false
				}

				if value != 0, value != solution[row][column] {
					return false
				}
			}
		}

		return true
	}

	private func isSolvedGrid(_ grid: [[Int]]) -> Bool {
		guard isValidShape(grid) else {
			return false
		}

		for index in 0..<Const.sideLength {
			let row: [Int] = grid[index]
			let column: [Int] = grid.map { $0[index] }
			guard containsDigitsOnce(row), containsDigitsOnce(column) else {
				return false
			}
		}

		let blockSize: Int = Int(Double(Const.sideLength).squareRoot())
		for row in stride(from: 0, to: Const.sideLength, by: blockSize) {
			for column in stride(from: 0, to: Const.sideLength, by: blockSize) {
				guard containsDigitsOnce(makeBlock(grid: grid, row: row, column: column, size: blockSize)) else {
					return false
				}
			}
		}

		return true
	}

	private func isValidShape(_ grid: [[Int]]) -> Bool {
		guard grid.count == Const.sideLength else {
			return false
		}

		for row in grid {
			guard row.count == Const.sideLength else {
				return false
			}

		}

		return true
	}

	private func containsDigitsOnce(_ values: [Int]) -> Bool {
		Set(values) == Set(1...9)
	}

	private func makeBlock(grid: [[Int]], row: Int, column: Int, size: Int) -> [Int] {
		var result: [Int] = []
		for rowIndex in row..<(row + size) {
			for columnIndex in column..<(column + size) {
				result.append(grid[rowIndex][columnIndex])
			}
		}

		return result
	}
}
