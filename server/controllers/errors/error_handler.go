package error_controllers

import (
	"wavelength/logging"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func ErrorHandler(ctx *fiber.Ctx, err error) error {
	code := fiber.StatusInternalServerError
	message := err.Error()

	if fiberErr, ok := err.(*fiber.Error); ok {
		code = fiberErr.Code
		message = fiberErr.Message

		switch code {
		case fiber.StatusMethodNotAllowed:
			return MethodNotAllowed(ctx)
		case fiber.StatusNotFound:
			return NotFound(ctx)
		}
	}

	go logging.Logger.Error(message, zap.Error(err))

	return ctx.Status(code).JSON(responses.Error{
		Success: false,
		Message: message,
	})
}
