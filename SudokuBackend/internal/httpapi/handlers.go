package httpapi

import (
	"encoding/json"
	"errors"
	"log"
	"net/http"

	"sudo/sudoku-backend/internal/service"
)

func (s *Server) handleHealth(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{
		"status": "ok",
	})
}

func (s *Server) handlePuzzle(w http.ResponseWriter, r *http.Request) {
	puzzle, err := s.puzzleService.LoadPuzzle(
		r.Context(),
		r.URL.Query().Get("difficulty"),
	)
	if err != nil {
		handlePuzzleError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, puzzle)
}

func handlePuzzleError(w http.ResponseWriter, err error) {
	if errors.Is(err, service.ErrUnsupportedDifficulty) {
		writeError(w, http.StatusBadRequest, "unsupported_difficulty")
		return
	}

	log.Printf("fetch puzzle error: %v", err)
	writeError(w, http.StatusBadGateway, "upstream_unavailable")
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
