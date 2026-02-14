package middleware

import (
	"strings"

	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"go.uber.org/zap"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
)

func JwtAuthMiddleware(ctx *fiber.Ctx) error {
	authorization := ctx.Get("Authorization")

	if authorization == "" {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	parts := strings.SplitN(authorization, " ", 2)

	if len(parts) != 2 || parts[0] != "Bearer" {
		return fiber.NewError(fiber.StatusUnauthorized, "Invalid Authorization header.")
	}

	tokenStr := parts[1]
	token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (any, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fiber.NewError(fiber.StatusUnauthorized, "Unexpected signing method.")
		}

		jwtSecret, err := shared_env.GetJwtSecret()
		if err != nil {
			logging.Logger.Error("JWT secret retrieval failed.", zap.Error(err))
			return nil, fiber.NewError(fiber.StatusUnauthorized, "JWT secret retrieval failed.")
		}

		return jwtSecret, nil
	})

	if err != nil || !token.Valid {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	claims, ok := token.Claims.(jwt.MapClaims)

	if !ok || !token.Valid {
		return fiber.NewError(fiber.StatusUnauthorized, "Invalid token claims.")
	}

	authUser := models.ClaimsToAuthUser(claims)

	ctx.Locals("authUser", authUser)
	return ctx.Next()
}
