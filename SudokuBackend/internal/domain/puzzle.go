package domain

type Puzzle struct {
	Difficulty       string  `json:"difficulty"`
	SourceDifficulty string  `json:"sourceDifficulty"`
	Puzzle           [][]int `json:"puzzle"`
	Solution         [][]int `json:"solution"`
}
