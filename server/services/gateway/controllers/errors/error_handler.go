package error_controllers

import (
	"wavelength/services/gateway/logging"
	"wavelength/services/gateway/models"

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
			return ctx.JSON(models.Error("Method not allowed."))
		case fiber.StatusNotFound:
			return ctx.JSON(models.Error(message))
		}
	}

	go logging.Logger.Error(message, zap.Error(err))

	return ctx.Status(code).JSON(models.Error(message))
}
