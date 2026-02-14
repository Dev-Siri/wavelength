package auth

import (
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"go.uber.org/zap"
)

// Deprecated: Present until next release of Wavelength. Auth has moved to be handled by oauth2 on Go instead of GenerateJwtToken simply acting as a token-generator.
func GenerateJwtToken(ctx *fiber.Ctx) error {
	var authUser models.AuthUser

	if err := ctx.BodyParser(&authUser); err != nil {
		logging.Logger.Error("Could not parse request body as an auth user object.", zap.Error(err))
		return fiber.NewError(fiber.StatusBadRequest, "Could not parse request body as an auth user object.")
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"userId":      authUser.UserID,
		"displayName": authUser.DisplayName,
		"pictureUrl":  authUser.PictureURL,
		"email":       authUser.Email,
	})

	jwtSecret, err := shared_env.GetJwtSecret()
	if err != nil {
		logging.Logger.Error("JWT secret retrieval failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "JWT secret retrieval failed.")
	}

	authToken, err := token.SignedString(jwtSecret)
	if err != nil {
		logging.Logger.Error("JWT token generation failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusBadRequest, "JWT token generation failed.")
	}

	return models.Success(ctx, authToken)
}
