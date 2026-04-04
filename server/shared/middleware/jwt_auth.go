package middleware

import (
	"strings"

	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
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

	const bearerPrefix = "Bearer "
	if !strings.HasPrefix(authorization, bearerPrefix) {
		return fiber.NewError(fiber.StatusUnauthorized, "Invalid Authorization header.")
	}

	tokenStr := authorization[len(bearerPrefix):]
	authUser, err := ParseAuthUser(tokenStr)
	if err != nil {
		return err
	}

	ctx.Locals("authUser", authUser)
	return ctx.Next()
}

func ParseAuthUser(tokenStr string) (shared_models.AuthUser, error) {
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
		return shared_models.AuthUser{}, fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	claims, ok := token.Claims.(jwt.MapClaims)

	if !ok || !token.Valid {
		return shared_models.AuthUser{}, fiber.NewError(fiber.StatusUnauthorized, "Invalid token claims.")
	}

	authUser := shared_models.ClaimsToAuthUser(claims)
	return authUser, nil
}
