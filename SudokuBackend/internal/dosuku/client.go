package dosuku

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"
)

type Client struct {
	httpClient  *http.Client
	upstreamURL string
}

type Board struct {
	Value      [][]int
	Solution   [][]int
	Difficulty string
}

type responseDTO struct {
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

const maxBodyBytes = 1 << 20

func NewClient(upstreamURL string, timeout time.Duration) *Client {
	return &Client{
		httpClient: &http.Client{
			Timeout: timeout,
		},
		upstreamURL: upstreamURL,
	}
}

func (c *Client) FetchBoards(ctx context.Context, limit int) ([]Board, error) {
	upstreamURL, err := c.makeUpstreamURL(limit)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, upstreamURL, nil)
	if err != nil {
		return nil, err
	}

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode < http.StatusOK || resp.StatusCode >= http.StatusMultipleChoices {
		return nil, fmt.Errorf("bad upstream status: %d", resp.StatusCode)
	}

	body := io.LimitReader(resp.Body, maxBodyBytes)
	var dto responseDTO
	if err := json.NewDecoder(body).Decode(&dto); err != nil {
		return nil, err
	}

	boards := make([]Board, 0, len(dto.Newboard.Grids))
	for _, grid := range dto.Newboard.Grids {
		boards = append(boards, Board{
			Value:      grid.Value,
			Solution:   grid.Solution,
			Difficulty: grid.Difficulty,
		})
	}

	return boards, nil
}

func (c *Client) makeUpstreamURL(limit int) (string, error) {
	parsed, err := url.Parse(c.upstreamURL)
	if err != nil {
		return "", err
	}

	query := parsed.Query()
	query.Set(
		"query",
		fmt.Sprintf(
			"{newboard(limit:%d){grids{value,solution,difficulty},results,message}}",
			limit,
		),
	)
	parsed.RawQuery = query.Encode()
	return parsed.String(), nil
}
