# Sudoku Backend

Go service for loading Sudoku puzzles for the iOS app. The app calls this backend, and the backend fetches ready-made puzzles from Dosuku.

## Structure

```text
cmd/server              entry point
internal/config         environment configuration
internal/domain         response models
internal/dosuku         Dosuku API client
internal/service        puzzle selection and validation
internal/httpapi        routes, handlers, middleware
```

## Run

```bash
go run ./cmd/server
```

Optional environment variables:

```bash
PORT=8080
DOSUKU_UPSTREAM_URL=https://sudoku-api.vercel.app/api/dosuku
DOSUKU_FETCH_LIMIT=10
DOSUKU_FETCH_ATTEMPTS=4
```

## Check

```bash
curl "http://127.0.0.1:8080/health"
curl "http://127.0.0.1:8080/v1/puzzles?difficulty=easy"
```

Supported network difficulties: `easy`, `medium`, `hard`.

## Test

```bash
go test ./...
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
