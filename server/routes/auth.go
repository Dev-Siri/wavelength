package routes

import (
	auth_controllers "wavelength/controllers/auth"

	"github.com/gofiber/fiber/v2"
)

func registerAuthRoutes(app *fiber.App) {
	app.Post("/auth/token", auth_controllers.GenerateJwtToken)
}
