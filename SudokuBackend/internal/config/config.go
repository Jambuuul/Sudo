package config

import (
	"os"
	"strconv"
	"strings"
	"time"
)

type Config struct {
	Port              string
	UpstreamURL       string
	FetchLimit        int
	FetchAttempts     int
	HTTPTimeout       time.Duration
	ReadHeaderTimeout time.Duration
}

const (
	defaultPort          = "8080"
	defaultUpstreamURL   = "https://sudoku-api.vercel.app/api/dosuku"
	defaultFetchLimit    = 10
	defaultFetchAttempts = 4
)

func Load() Config {
	return Config{
		Port:              envString("PORT", defaultPort),
		UpstreamURL:       envString("DOSUKU_UPSTREAM_URL", defaultUpstreamURL),
		FetchLimit:        envInt("DOSUKU_FETCH_LIMIT", defaultFetchLimit),
		FetchAttempts:     envInt("DOSUKU_FETCH_ATTEMPTS", defaultFetchAttempts),
		HTTPTimeout:       5 * time.Second,
		ReadHeaderTimeout: 3 * time.Second,
	}
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
