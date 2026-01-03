package error_controllers

import (
	"wavelength/services/gateway/models"

	"github.com/gofiber/fiber/v2"
)

func ErrorHandler(ctx *fiber.Ctx, err error) error {
	code := fiber.StatusInternalServerError
	message := err.Error()

	if fiberErr, ok := err.(*fiber.Error); ok {
		code = fiberErr.Code
		message = fiberErr.Message

		switch code {
		case fiber.StatusMethodNotAllowed:
			return models.Error(ctx, "Method not allowed.")
		case fiber.StatusNotFound:
			return models.Error(ctx, message)
		}
	}

	ctx.Status(code)
	return models.Error(ctx, message)
}
