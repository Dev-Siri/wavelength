package auth

import (
	"github.com/Dev-Siri/wavelength/server/proto/authpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func OAuthGoogleCallback(ctx *fiber.Ctx) error {
	code := ctx.Query("code")
	if code == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Missing code in callback.")
	}

	state := ctx.Query("state")
	if state == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Missing state in callback.")
	}

	oauthCallbackResponse, err := clients.AuthClient.OAuthCallback(ctx.Context(), &authpb.OAuthCallbackRequest{
		Code:  code,
		State: state,
	})
	if err != nil {
		logging.Logger.Error("AuthService: 'OAuthCallback' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "OAuth callback failed.")
	}

	return ctx.Redirect(oauthCallbackResponse.SignedUri, fiber.StatusSeeOther)
}
