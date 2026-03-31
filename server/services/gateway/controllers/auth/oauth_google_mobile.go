package auth

import (
	"github.com/Dev-Siri/wavelength/server/proto/authpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func OAuthGoogleMobile(ctx *fiber.Ctx) error {
	serverAuthCode := ctx.Query("code")
	if serverAuthCode == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Missing code.")
	}

	oauthRedirectResponse, err := clients.AuthClient.MobileOAuth(ctx.Context(), &authpb.MobileOAuthRequest{
		ServerAuthCode: serverAuthCode,
	})
	if err != nil {
		logging.Logger.Error("AuthService: 'MobileOAuth' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Mobile OAuth failed.")
	}

	return shared_models.Success(ctx, oauthRedirectResponse)
}
