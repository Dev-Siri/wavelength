package responses

type Success[T any] struct {
	Success bool `json:"success"`
	Data    T    `json:"data"`
}
