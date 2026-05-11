package service

import (
	"context"
	"errors"

	"sudo/sudoku-backend/internal/domain"
	"sudo/sudoku-backend/internal/dosuku"
)

type DosukuClient interface {
	FetchBoards(ctx context.Context, limit int) ([]dosuku.Board, error)
}

type PuzzleService struct {
	dosukuClient  DosukuClient
	fetchLimit    int
	fetchAttempts int
}

var (
	ErrUnsupportedDifficulty = errors.New("unsupported difficulty")
	ErrEmptyUpstreamResponse = errors.New("empty upstream response")
	ErrNoMatchingDifficulty  = errors.New("no matching difficulty")
)

func NewPuzzleService(dosukuClient DosukuClient, fetchLimit int, fetchAttempts int) *PuzzleService {
	return &PuzzleService{
		dosukuClient:  dosukuClient,
		fetchLimit:    fetchLimit,
		fetchAttempts: fetchAttempts,
	}
}

func (s *PuzzleService) LoadPuzzle(ctx context.Context, requestedDifficulty string) (domain.Puzzle, error) {
	difficulty := normalizeRequestedDifficulty(requestedDifficulty)
	if difficulty == "" {
		return domain.Puzzle{}, ErrUnsupportedDifficulty
	}

	var lastFetchError error
	for attempt := 0; attempt < s.fetchAttempts; attempt++ {
		boards, err := s.dosukuClient.FetchBoards(ctx, s.fetchLimit)
		if err != nil {
			lastFetchError = err
			continue
		}

		puzzle, err := selectPuzzle(boards, difficulty)
		if err == nil {
			return puzzle, nil
		}

		if !errors.Is(err, ErrNoMatchingDifficulty) {
			return domain.Puzzle{}, err
		}
	}

	if lastFetchError != nil {
		return domain.Puzzle{}, lastFetchError
	}

	return domain.Puzzle{}, ErrNoMatchingDifficulty
}

func selectPuzzle(boards []dosuku.Board, requestedDifficulty string) (domain.Puzzle, error) {
	if len(boards) == 0 {
		return domain.Puzzle{}, ErrEmptyUpstreamResponse
	}

	selectedIndex := -1

	for index, board := range boards {
		if normalizeSourceDifficulty(board.Difficulty) == requestedDifficulty && isValidBoard(board) {
			selectedIndex = index
			break
		}
	}

	if selectedIndex == -1 {
		return domain.Puzzle{}, ErrNoMatchingDifficulty
	}

	board := boards[selectedIndex]
	return domain.Puzzle{
		Difficulty:       requestedDifficulty,
		SourceDifficulty: normalizeSourceDifficulty(board.Difficulty),
		Puzzle:           board.Value,
		Solution:         board.Solution,
	}, nil
}

func isValidBoard(board dosuku.Board) bool {
	return isValidPuzzleGrid(board.Value, board.Solution) && isSolvedGrid(board.Solution)
}

func isValidPuzzleGrid(puzzle [][]int, solution [][]int) bool {
	if !hasValidShape(puzzle) || !hasValidShape(solution) {
		return false
	}

	for row := range puzzle {
		for column, value := range puzzle[row] {
			if value < 0 || value > 9 {
				return false
			}

			if value != 0 && value != solution[row][column] {
				return false
			}
		}
	}

	return true
}

func isSolvedGrid(grid [][]int) bool {
	if !hasValidShape(grid) {
		return false
	}

	for index := 0; index < 9; index++ {
		if !containsDigitsOnce(grid[index]) || !containsDigitsOnce(makeColumn(grid, index)) {
			return false
		}
	}

	for row := 0; row < 9; row += 3 {
		for column := 0; column < 9; column += 3 {
			if !containsDigitsOnce(makeBox(grid, row, column)) {
				return false
			}
		}
	}

	return true
}

func hasValidShape(grid [][]int) bool {
	if len(grid) != 9 {
		return false
	}

	for _, row := range grid {
		if len(row) != 9 {
			return false
		}
	}

	return true
}

func containsDigitsOnce(values []int) bool {
	seen := make([]bool, 10)

	for _, value := range values {
		if value < 1 || value > 9 || seen[value] {
			return false
		}

		seen[value] = true
	}

	return true
}

func makeColumn(grid [][]int, column int) []int {
	values := make([]int, 0, 9)
	for row := 0; row < 9; row++ {
		values = append(values, grid[row][column])
	}

	return values
}

func makeBox(grid [][]int, startRow int, startColumn int) []int {
	values := make([]int, 0, 9)
	for row := startRow; row < startRow+3; row++ {
		for column := startColumn; column < startColumn+3; column++ {
			values = append(values, grid[row][column])
		}
	}

	return values
}
