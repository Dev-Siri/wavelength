package routes

import (
	region_controllers "wavelength/controllers/region"

	"github.com/gofiber/fiber/v2"
)

func registerRegionRoutes(app *fiber.App) {
	app.Get("/region", region_controllers.GetRegion)
}
