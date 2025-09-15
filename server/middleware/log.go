package middleware

import (
	"wavelength/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func LogMiddleware(c *fiber.Ctx) error {
	go logging.Logger.Info("Incoming Request.",
		zap.String("Method", c.Method()),
		zap.String("URL", c.OriginalURL()),
	)

	err := c.Next()

	return err
}
