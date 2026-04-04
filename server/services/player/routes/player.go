package routes

import (
	player_controllers "github.com/Dev-Siri/wavelength/server/services/player/controllers/player"
	"github.com/Dev-Siri/wavelength/server/shared/middleware"
	"github.com/gofiber/fiber/v2"
)

func registerPlayerRoutes(app *fiber.App) {
	app.Post("/player/record", middleware.JwtAuthMiddleware, player_controllers.RecordStream)
}
