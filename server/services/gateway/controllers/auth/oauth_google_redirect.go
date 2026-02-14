package auth

import (
	"github.com/Dev-Siri/wavelength/server/proto/authpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/utils"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func OAuthGoogleRedirect(ctx *fiber.Ctx) error {
	redirectURI := ctx.Query("redirectUri")
	if !utils.IsValidUrl(redirectURI) {
		return fiber.NewError(fiber.StatusBadRequest, "Invalid redirect URI.")
	}

	oauthRedirectResponse, err := clients.AuthClient.GetOAuthRedirectUrl(ctx.Context(), &authpb.GetOAuthRedirectUrlRequest{
		RedirectUri: redirectURI,
	})
	if err != nil {
		logging.Logger.Error("AuthService: 'GetOAuthRedirectUrl' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "OAuth redirect URI retrieval failed.")
	}

	return ctx.Redirect(oauthRedirectResponse.OauthUri, fiber.StatusTemporaryRedirect)
}
