package apicontrollers

import (
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
)

func GenericErrorHandler(ctx *fiber.Ctx, err error) error {
	code := fiber.StatusInternalServerError
	message := err.Error()

	if fiberErr, ok := err.(*fiber.Error); ok {
		code = fiberErr.Code
		message = fiberErr.Message

		switch code {
		case fiber.StatusMethodNotAllowed:
			return shared_models.Error(ctx, "Method not allowed.")
		case fiber.StatusNotFound:
			return shared_models.Error(ctx, message)
		}
	}

	ctx.Status(code)
	return shared_models.Error(ctx, message)
}
