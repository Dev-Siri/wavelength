package auth

import (
	"github.com/Dev-Siri/wavelength/server/proto/authpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func ConsumeAuthToken(ctx *fiber.Ctx) error {
	authCode := ctx.Query("code")
	if authCode == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Missing code.")
	}

	consumeAuthTokenResponse, err := clients.AuthClient.ConsumeAuthToken(ctx.Context(), &authpb.ConsumeAuthTokenRequest{
		AuthCode: authCode,
	})
	if err != nil {
		logging.Logger.Error("AuthService: 'ConsumeAuthToken' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Auth token consumption failed.")
	}

	return models.Success(ctx, consumeAuthTokenResponse)
}
