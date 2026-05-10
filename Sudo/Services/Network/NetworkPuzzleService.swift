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
		static let baseURL: String = "http://127.0.0.1:8080/v1"
		static let puzzlesPath: String = "puzzles"
		static let killerPuzzlesPath: String = "killer-puzzles"
		static let difficultyQueryName: String = "difficulty"
		static let successStatusRange: ClosedRange<Int> = 200...299
		static let sideLength: Int = SudokuBoard.sideLength
		static let cellCount: Int = SudokuBoard.sideLength * SudokuBoard.sideLength
	}

	// MARK: - Fields
	private let session: URLSession

	// MARK: - Lifecycle
	init(session: URLSession = .shared) {
		self.session = session
	}

	// MARK: - Public methods
	func loadPuzzle(difficulty: SudokuDifficulty) async throws -> NetworkPuzzle {
		let data: Data = try await loadData(path: Const.puzzlesPath, difficulty: difficulty)
		let puzzle: NetworkPuzzle = try JSONDecoder().decode(NetworkPuzzle.self, from: data)
		guard isValidGrid(puzzle.puzzle), isValidGrid(puzzle.solution) else {
			throw NetworkPuzzleServiceError.invalidPuzzle
		}

		return puzzle
	}

	func loadKillerPuzzle(difficulty: SudokuDifficulty) async throws -> NetworkKillerPuzzle {
		let data: Data = try await loadData(path: Const.killerPuzzlesPath, difficulty: difficulty)
		let puzzle: NetworkKillerPuzzle = try JSONDecoder().decode(NetworkKillerPuzzle.self, from: data)
		guard isValidGrid(puzzle.puzzle),
			  isValidGrid(puzzle.solution),
			  isValidCages(puzzle.cages)
		else {
			throw NetworkPuzzleServiceError.invalidPuzzle
		}

		return puzzle
	}

	// MARK: - Private methods
	private func loadData(path: String, difficulty: SudokuDifficulty) async throws -> Data {
		guard let baseURL: URL = URL(string: Const.baseURL) else {
			throw NetworkPuzzleServiceError.invalidURL
		}

		let url: URL = baseURL.appendingPathComponent(path)
		guard var components: URLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			throw NetworkPuzzleServiceError.invalidURL
		}

		components.queryItems = [
			URLQueryItem(name: Const.difficultyQueryName, value: difficulty.rawValue)
		]

		guard let requestURL: URL = components.url else {
			throw NetworkPuzzleServiceError.invalidURL
		}

		let (data, response) = try await session.data(from: requestURL)
		guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse,
			  Const.successStatusRange.contains(httpResponse.statusCode)
		else {
			throw NetworkPuzzleServiceError.invalidResponse
		}

		return data
	}

	private func isValidGrid(_ grid: [[Int]]) -> Bool {
		guard grid.count == Const.sideLength else {
			return false
		}

		for row in grid {
			guard row.count == Const.sideLength else {
				return false
			}

			for value in row where !(0...9).contains(value) {
				return false
			}
		}

		return true
	}

	private func isValidCages(_ cages: [NetworkKillerCage]) -> Bool {
		guard !cages.isEmpty else {
			return false
		}

		var usedCells: Set<Int> = []
		for cage in cages {
			guard cage.sum > 0, !cage.cells.isEmpty else {
				return false
			}

			for cell in cage.cells {
				guard (0..<Const.cellCount).contains(cell), !usedCells.contains(cell) else {
					return false
				}

				usedCells.insert(cell)
			}
		}

		return usedCells.count == Const.cellCount
	}
}
