package service

import "strings"

func normalizeRequestedDifficulty(value string) string {
	switch strings.TrimSpace(value) {
	case "", "easy":
		return "easy"
	case "medium":
		return "medium"
	case "hard":
		return "hard"
	default:
		return ""
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
