package middleware

import (
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func LogMiddleware(ctx *fiber.Ctx) error {
	go logging.Logger.Info("Incoming Request.",
		zap.String("method", ctx.Method()),
		zap.String("url", ctx.OriginalURL()),
		zap.String("userAgent", string(ctx.Request().Header.UserAgent())),
		zap.String("clientIp", ctx.IP()),
	)

	return ctx.Next()
}
