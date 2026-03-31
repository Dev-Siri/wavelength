package apicontrollers

import (
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"

	"github.com/gofiber/fiber/v2"
)

func RateLimitExceededHandler(ctx *fiber.Ctx) error {
	ctx.Status(fiber.StatusTooManyRequests)
	return shared_models.Error(ctx, "Rate limit exceeded.")
}
