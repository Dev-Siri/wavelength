package auth

import (
	"encoding/json"
	"wavelength/services/gateway/env"
	"wavelength/services/gateway/models"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
)

func GenerateJwtToken(ctx *fiber.Ctx) error {
	var authUser models.AuthUser

	if err := json.Unmarshal(ctx.Body(), &authUser); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "Could not parse request body as an auth user object: "+err.Error())
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"id":          authUser.Id,
		"displayName": authUser.DisplayName,
		"photoUrl":    authUser.PhotoUrl,
		"email":       authUser.Email,
	})

	authToken, err := token.SignedString(env.GetJwtSecret())

	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "Failed to generate JWT token: "+err.Error())
	}

	return models.Success(ctx, authToken)
}
