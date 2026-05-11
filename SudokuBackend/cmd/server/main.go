package main

import (
	"log"
	"net/http"

	"sudo/sudoku-backend/internal/config"
	"sudo/sudoku-backend/internal/dosuku"
	"sudo/sudoku-backend/internal/httpapi"
	"sudo/sudoku-backend/internal/service"
)

func main() {
	cfg := config.Load()

	dosukuClient := dosuku.NewClient(cfg.UpstreamURL, cfg.HTTPTimeout)
	puzzleService := service.NewPuzzleService(dosukuClient, cfg.FetchLimit, cfg.FetchAttempts)
	apiServer := httpapi.NewServer(puzzleService)

	httpServer := &http.Server{
		Addr:              ":" + cfg.Port,
		Handler:           apiServer.Handler(),
		ReadHeaderTimeout: cfg.ReadHeaderTimeout,
	}

	log.Printf("server started on :%s", cfg.Port)
	log.Fatal(httpServer.ListenAndServe())
}
