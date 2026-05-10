package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"
)

type puzzleResponse struct {
	Difficulty       string  `json:"difficulty"`
	SourceDifficulty string  `json:"sourceDifficulty"`
	Puzzle           [][]int `json:"puzzle"`
	Solution         [][]int `json:"solution"`
}

type killerPuzzleResponse struct {
	Difficulty string               `json:"difficulty"`
	Puzzle     [][]int              `json:"puzzle"`
	Solution   [][]int              `json:"solution"`
	Cages      []killerCageResponse `json:"cages"`
}

type killerCageResponse struct {
	ID    int   `json:"id"`
	Sum   int   `json:"sum"`
	Cells []int `json:"cells"`
}

type dosukuResponse struct {
	Newboard struct {
		Grids []struct {
			Value      [][]int `json:"value"`
			Solution   [][]int `json:"solution"`
			Difficulty string  `json:"difficulty"`
		} `json:"grids"`
		Results int    `json:"results"`
		Message string `json:"message"`
	} `json:"newboard"`
}

type server struct {
	client      *http.Client
	upstreamURL string
	fetchLimit  int
}

const (
	defaultPort        = "8080"
	defaultUpstreamURL = "https://sudoku-api.vercel.app/api/dosuku"
	defaultFetchLimit  = 5
	maxBodyBytes       = 1 << 20
)

func main() {
	s := server{
		client: &http.Client{
			Timeout: 5 * time.Second,
		},
		upstreamURL: envString("DOSUKU_UPSTREAM_URL", defaultUpstreamURL),
		fetchLimit:  envInt("DOSUKU_FETCH_LIMIT", defaultFetchLimit),
	}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", s.handleHealth)
	mux.HandleFunc("GET /v1/puzzles", s.handlePuzzle)
	mux.HandleFunc("GET /v1/killer-puzzles", s.handleKillerPuzzle)

	port := envString("PORT", defaultPort)
	httpServer := &http.Server{
		Addr:              ":" + port,
		Handler:           logMiddleware(mux),
		ReadHeaderTimeout: 3 * time.Second,
	}

	log.Printf("server started on :%s", port)
	log.Fatal(httpServer.ListenAndServe())
}

func (s server) handleHealth(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{
		"status": "ok",
	})
}

func (s server) handlePuzzle(w http.ResponseWriter, r *http.Request) {
	difficulty := normalizeRequestedDifficulty(r.URL.Query().Get("difficulty"))
	if difficulty == "" {
		writeError(w, http.StatusBadRequest, "unsupported_difficulty")
		return
	}

	puzzle, err := s.fetchPuzzle(r.Context(), difficulty)
	if err != nil {
		log.Printf("fetch puzzle error: %v", err)
		writeError(w, http.StatusBadGateway, "upstream_unavailable")
		return
	}

	writeJSON(w, http.StatusOK, puzzle)
}

func (s server) handleKillerPuzzle(w http.ResponseWriter, r *http.Request) {
	difficulty := normalizeRequestedDifficulty(r.URL.Query().Get("difficulty"))
	if difficulty == "" {
		writeError(w, http.StatusBadRequest, "unsupported_difficulty")
		return
	}

	writeJSON(w, http.StatusOK, makeKillerPuzzle(difficulty))
}

func (s server) fetchPuzzle(ctx context.Context, requestedDifficulty string) (puzzleResponse, error) {
	upstreamURL, err := s.makeUpstreamURL()
	if err != nil {
		return puzzleResponse{}, err
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, upstreamURL, nil)
	if err != nil {
		return puzzleResponse{}, err
	}

	resp, err := s.client.Do(req)
	if err != nil {
		return puzzleResponse{}, err
	}
	defer resp.Body.Close()

	if resp.StatusCode < http.StatusOK || resp.StatusCode >= http.StatusMultipleChoices {
		return puzzleResponse{}, fmt.Errorf("bad upstream status: %d", resp.StatusCode)
	}

	body := io.LimitReader(resp.Body, maxBodyBytes)
	var dto dosukuResponse
	if err := json.NewDecoder(body).Decode(&dto); err != nil {
		return puzzleResponse{}, err
	}

	return selectPuzzle(dto, requestedDifficulty)
}

func (s server) makeUpstreamURL() (string, error) {
	parsed, err := url.Parse(s.upstreamURL)
	if err != nil {
		return "", err
	}

	query := parsed.Query()
	query.Set(
		"query",
		fmt.Sprintf(
			"{newboard(limit:%d){grids{value,solution,difficulty},results,message}}",
			s.fetchLimit,
		),
	)
	parsed.RawQuery = query.Encode()
	return parsed.String(), nil
}

func selectPuzzle(dto dosukuResponse, requestedDifficulty string) (puzzleResponse, error) {
	if len(dto.Newboard.Grids) == 0 {
		return puzzleResponse{}, errors.New("empty upstream response")
	}

	target := targetSourceDifficulty(requestedDifficulty)
	selectedIndex := -1

	for index, grid := range dto.Newboard.Grids {
		if normalizeSourceDifficulty(grid.Difficulty) == target && isValidGrid(grid.Value) && isValidGrid(grid.Solution) {
			selectedIndex = index
			break
		}
	}

	if selectedIndex == -1 {
		for index, grid := range dto.Newboard.Grids {
			if isValidGrid(grid.Value) && isValidGrid(grid.Solution) {
				selectedIndex = index
				break
			}
		}
	}

	if selectedIndex == -1 {
		return puzzleResponse{}, errors.New("no valid grid in upstream response")
	}

	grid := dto.Newboard.Grids[selectedIndex]
	return puzzleResponse{
		Difficulty:       requestedDifficulty,
		SourceDifficulty: normalizeSourceDifficulty(grid.Difficulty),
		Puzzle:           grid.Value,
		Solution:         grid.Solution,
	}, nil
}

func normalizeRequestedDifficulty(value string) string {
	switch strings.TrimSpace(value) {
	case "", "easy":
		return "easy"
	case "veryEasy":
		return "veryEasy"
	case "medium":
		return "medium"
	case "hard":
		return "hard"
	case "expert":
		return "expert"
	case "master":
		return "master"
	default:
		return ""
	}
}

func targetSourceDifficulty(value string) string {
	switch value {
	case "medium":
		return "medium"
	case "hard", "expert", "master":
		return "hard"
	default:
		return "easy"
	}
}

func normalizeSourceDifficulty(value string) string {
	switch strings.ToLower(strings.TrimSpace(value)) {
	case "easy":
		return "easy"
	case "medium":
		return "medium"
	case "hard":
		return "hard"
	default:
		return "unknown"
	}
}

func isValidGrid(grid [][]int) bool {
	if len(grid) != 9 {
		return false
	}

	for _, row := range grid {
		if len(row) != 9 {
			return false
		}

		for _, value := range row {
			if value < 0 || value > 9 {
				return false
			}
		}
	}

	return true
}

func makeKillerPuzzle(difficulty string) killerPuzzleResponse {
	solution := defaultKillerSolution()
	return killerPuzzleResponse{
		Difficulty: difficulty,
		Puzzle:     makeEmptyPuzzle(),
		Solution:   solution,
		Cages:      makeDefaultKillerCages(solution),
	}
}

func makeEmptyPuzzle() [][]int {
	puzzle := make([][]int, 9)
	for row := range puzzle {
		puzzle[row] = make([]int, 9)
	}

	return puzzle
}

func defaultKillerSolution() [][]int {
	return [][]int{
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
}

func makeDefaultKillerCages(solution [][]int) []killerCageResponse {
	groups := [][]int{
		{0, 1, 9},
		{2, 10, 11},
		{18, 19, 20},
		{3, 4, 12},
		{5, 13, 14},
		{21, 22, 23},
		{6, 15, 16},
		{7, 8, 17},
		{24, 25, 26},
		{27, 36, 37},
		{28, 29, 38},
		{45, 46, 47},
		{30, 31, 39},
		{32, 40, 41},
		{48, 49, 50},
		{33, 42, 43},
		{34, 35, 44},
		{51, 52, 53},
		{54, 55, 63},
		{56, 64, 65},
		{72, 73, 74},
		{57, 58, 66},
		{59, 67, 68},
		{75, 76, 77},
		{60, 69, 70},
		{61, 62, 71},
		{78, 79, 80},
	}

	cages := make([]killerCageResponse, 0, len(groups))
	for index, cells := range groups {
		sum := 0
		for _, cell := range cells {
			row := cell / 9
			column := cell % 9
			sum += solution[row][column]
		}

		cages = append(cages, killerCageResponse{
			ID:    index + 1,
			Sum:   sum,
			Cells: cells,
		})
	}

	return cages
}

func writeJSON(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	if err := json.NewEncoder(w).Encode(value); err != nil {
		log.Printf("write json error: %v", err)
	}
}

func writeError(w http.ResponseWriter, status int, code string) {
	writeJSON(w, status, map[string]string{
		"error": code,
	})
}

func logMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		log.Printf("%s %s %s", r.Method, r.URL.Path, time.Since(start))
	})
}

func envString(key string, fallback string) string {
	value := strings.TrimSpace(os.Getenv(key))
	if value == "" {
		return fallback
	}
	return strings.Trim(value, "\"")
}

func envInt(key string, fallback int) int {
	value := strings.TrimSpace(os.Getenv(key))
	if value == "" {
		return fallback
	}

	result, err := strconv.Atoi(value)
	if err != nil || result <= 0 {
		return fallback
	}

	return result
}
