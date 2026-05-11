package service

import (
	"context"
	"errors"
	"testing"

	"sudo/sudoku-backend/internal/dosuku"
)

type fakeDosukuClient struct {
	boardBatches [][]dosuku.Board
	err          error
	callCount    int
}

func (c *fakeDosukuClient) FetchBoards(_ context.Context, _ int) ([]dosuku.Board, error) {
	if c.err != nil {
		return nil, c.err
	}

	index := c.callCount
	c.callCount++
	if len(c.boardBatches) == 0 {
		return nil, nil
	}

	if index >= len(c.boardBatches) {
		index = len(c.boardBatches) - 1
	}

	return c.boardBatches[index], nil
}

func TestLoadPuzzleSelectsRequestedSourceDifficulty(t *testing.T) {
	client := &fakeDosukuClient{
		boardBatches: [][]dosuku.Board{
			{
				makeBoard("easy"),
				makeBoard("hard"),
			},
		},
	}
	service := NewPuzzleService(
		client,
		2,
		1,
	)

	puzzle, err := service.LoadPuzzle(context.Background(), "hard")
	if err != nil {
		t.Fatalf("LoadPuzzle returned error: %v", err)
	}

	if puzzle.Difficulty != "hard" {
		t.Fatalf("Difficulty = %q, want %q", puzzle.Difficulty, "hard")
	}

	if puzzle.SourceDifficulty != "hard" {
		t.Fatalf("SourceDifficulty = %q, want %q", puzzle.SourceDifficulty, "hard")
	}
}

func TestLoadPuzzleRetriesUntilRequestedDifficultyAppears(t *testing.T) {
	client := &fakeDosukuClient{
		boardBatches: [][]dosuku.Board{
			{
				makeBoard("easy"),
			},
			{
				makeBoard("medium"),
			},
		},
	}
	service := NewPuzzleService(
		client,
		1,
		2,
	)

	puzzle, err := service.LoadPuzzle(context.Background(), "medium")
	if err != nil {
		t.Fatalf("LoadPuzzle returned error: %v", err)
	}

	if puzzle.Difficulty != "medium" {
		t.Fatalf("Difficulty = %q, want %q", puzzle.Difficulty, "medium")
	}

	if puzzle.SourceDifficulty != "medium" {
		t.Fatalf("SourceDifficulty = %q, want %q", puzzle.SourceDifficulty, "medium")
	}

	if client.callCount != 2 {
		t.Fatalf("callCount = %d, want %d", client.callCount, 2)
	}
}

func TestLoadPuzzleRejectsUnsupportedDifficulty(t *testing.T) {
	service := NewPuzzleService(&fakeDosukuClient{}, 1, 1)

	_, err := service.LoadPuzzle(context.Background(), "veryEasy")
	if !errors.Is(err, ErrUnsupportedDifficulty) {
		t.Fatalf("error = %v, want %v", err, ErrUnsupportedDifficulty)
	}
}

func TestLoadPuzzleDoesNotReturnDifferentDifficulty(t *testing.T) {
	service := NewPuzzleService(
		&fakeDosukuClient{
			boardBatches: [][]dosuku.Board{
				{
					makeBoard("hard"),
				},
			},
		},
		1,
		1,
	)

	_, err := service.LoadPuzzle(context.Background(), "easy")
	if !errors.Is(err, ErrNoMatchingDifficulty) {
		t.Fatalf("error = %v, want %v", err, ErrNoMatchingDifficulty)
	}
}

func TestLoadPuzzleRejectsInvalidSolution(t *testing.T) {
	service := NewPuzzleService(
		&fakeDosukuClient{
			boardBatches: [][]dosuku.Board{
				{
					makeInvalidBoard("easy"),
				},
			},
		},
		1,
		1,
	)

	_, err := service.LoadPuzzle(context.Background(), "easy")
	if !errors.Is(err, ErrNoMatchingDifficulty) {
		t.Fatalf("error = %v, want %v", err, ErrNoMatchingDifficulty)
	}
}

func makeBoard(difficulty string) dosuku.Board {
	grid := [][]int{
		{5, 3, 4, 6, 7, 8, 9, 1, 2},
		{6, 7, 2, 1, 9, 5, 3, 4, 8},
		{1, 9, 8, 3, 4, 2, 5, 6, 7},
		{8, 5, 9, 7, 6, 1, 4, 2, 3},
		{4, 2, 6, 8, 5, 3, 7, 9, 1},
		{7, 1, 3, 9, 2, 4, 8, 5, 6},
		{9, 6, 1, 5, 3, 7, 2, 8, 4},
		{2, 8, 7, 4, 1, 9, 6, 3, 5},
		{3, 4, 5, 2, 8, 6, 1, 7, 9},
	}

	return dosuku.Board{
		Value:      grid,
		Solution:   grid,
		Difficulty: difficulty,
	}
}

func makeInvalidBoard(difficulty string) dosuku.Board {
	board := makeBoard(difficulty)
	board.Solution[0][0] = board.Solution[0][1]
	return board
}
