package routes

import (
	auth_controllers "wavelength/services/gateway/controllers/auth"

	"github.com/gofiber/fiber/v2"
)

func registerAuthRoutes(app *fiber.App) {
	app.Post("/auth/token", auth_controllers.GenerateJwtToken)
}
