package error_controllers

import (
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"

	"github.com/gofiber/fiber/v2"
)

func RateLimitExceededHandler(ctx *fiber.Ctx) error {
	ctx.Status(fiber.StatusTooManyRequests)
	return models.Error(ctx, "Rate limit exceeded.")
}
