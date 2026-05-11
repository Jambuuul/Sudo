package httpapi

import (
	"net/http"

	"sudo/sudoku-backend/internal/service"
)

type Server struct {
	puzzleService *service.PuzzleService
}

func NewServer(puzzleService *service.PuzzleService) *Server {
	return &Server{
		puzzleService: puzzleService,
	}
}

func (s *Server) Handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", s.handleHealth)
	mux.HandleFunc("GET /v1/puzzles", s.handlePuzzle)
	return logMiddleware(mux)
}
