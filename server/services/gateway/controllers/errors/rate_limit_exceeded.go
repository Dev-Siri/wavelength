package error_controllers

import (
	"wavelength/services/gateway/models"

	"github.com/gofiber/fiber/v2"
)

func RateLimitExceededHandler(ctx *fiber.Ctx) error {
	ctx.Status(fiber.StatusTooManyRequests)
	return models.Error(ctx, "Rate limit exceeded.")
}
