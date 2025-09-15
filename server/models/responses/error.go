package responses

type Error struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
}
