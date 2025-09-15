package error_controllers

import (
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
)

func NotFound(ctx *fiber.Ctx) error {
	return ctx.Status(fiber.StatusNotFound).JSON(
		&responses.Error{Message: "Not found."},
	)
}
