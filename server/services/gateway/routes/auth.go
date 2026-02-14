package routes

import (
	auth_controllers "github.com/Dev-Siri/wavelength/server/services/gateway/controllers/auth"
	"github.com/Dev-Siri/wavelength/server/services/gateway/middleware"

	"github.com/gofiber/fiber/v2"
)

func registerAuthRoutes(app *fiber.App) {
	auth := app.Group("/auth")

	auth.Get("/login/google", auth_controllers.OAuthGoogleRedirect)
	auth.Get("/login/google/mobile", auth_controllers.OAuthGoogleMobile)
	auth.Get("/callback/google", auth_controllers.OAuthGoogleCallback)

	auth.Get("/profile", middleware.JwtAuthMiddleware, auth_controllers.GetProfile)
	auth.Get("/token/consume", auth_controllers.ConsumeAuthToken)

	auth.Post("/token", auth_controllers.GenerateJwtToken)
}
