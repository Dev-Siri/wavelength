package auth

import (
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/gofiber/fiber/v2"
)

func GetProfile(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)
	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	return models.Success(ctx, authUser)
}
