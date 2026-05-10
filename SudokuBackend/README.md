# Sudoku Backend

Small Go adapter for the iOS app. The app calls this service, and the service fetches ready-made classic puzzles from Dosuku.
Killer Sudoku uses the same app-facing backend contract, but currently returns a server-side catalog because a stable public Killer Sudoku JSON API with cages is not configured.

## Run

```bash
go run ./cmd/server
```

Optional environment variables:

```bash
PORT=8080
DOSUKU_UPSTREAM_URL=https://sudoku-api.vercel.app/api/dosuku
DOSUKU_FETCH_LIMIT=5
```

## Check

```bash
curl "http://127.0.0.1:8080/health"
curl "http://127.0.0.1:8080/v1/puzzles?difficulty=easy"
curl "http://127.0.0.1:8080/v1/killer-puzzles?difficulty=easy"
```

Response shape:

```json
{
  "difficulty": "easy",
  "sourceDifficulty": "easy",
  "puzzle": [[0]],
  "solution": [[0]]
}
```

Killer response shape:

```json
{
  "difficulty": "easy",
  "puzzle": [[0]],
  "solution": [[0]],
  "cages": [
    {
      "id": 1,
      "sum": 12,
      "cells": [0, 1, 9]
    }
  ]
}
```
