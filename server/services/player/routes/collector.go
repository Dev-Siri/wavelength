package routes

import (
	collector_controllers "github.com/Dev-Siri/wavelength/server/services/player/controllers/collector"
	"github.com/gofiber/fiber/v2"
)

func registerCollectorRoutes(app *fiber.App) {
	app.Post("/collector/:videoId", collector_controllers.CollectStream)
}
