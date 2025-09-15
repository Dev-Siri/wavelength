package error_controllers

import (
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
)

func MethodNotAllowed(ctx *fiber.Ctx) error {
	return ctx.Status(fiber.StatusMethodNotAllowed).JSON(
		&responses.Error{Message: "Method not allowed."},
	)
}
