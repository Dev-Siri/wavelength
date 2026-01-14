package auth

import (
	"wavelength/services/gateway/env"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"go.uber.org/zap"
)

func GenerateJwtToken(ctx *fiber.Ctx) error {
	var authUser models.AuthUser

	if err := ctx.BodyParser(&authUser); err != nil {
		logging.Logger.Error("Could not parse request body as an auth user object.", zap.Error(err))
		return fiber.NewError(fiber.StatusBadRequest, "Could not parse request body as an auth user object.")
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"id":          authUser.Id,
		"displayName": authUser.DisplayName,
		"photoUrl":    authUser.PhotoUrl,
		"email":       authUser.Email,
	})

	authToken, err := token.SignedString(env.GetJwtSecret())
	if err != nil {
		logging.Logger.Error("JWT token generation failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusBadRequest, "JWT token generation failed.")
	}

	return models.Success(ctx, authToken)
}
