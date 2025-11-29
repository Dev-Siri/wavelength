package responses

import "github.com/gofiber/fiber/v2"

func Success[T any](data T) *fiber.Map {
	return &fiber.Map{
		"success": true,
		"data":    data,
	}
}

func Error(message string) *fiber.Map {
	return &fiber.Map{
		"success": false,
		"message": message,
	}
}
