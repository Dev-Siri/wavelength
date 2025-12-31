package routes

import (
	image_controllers "wavelength/services/gateway/controllers/image"

	"github.com/gofiber/fiber/v2"
)

func registerImageRoutes(app *fiber.App) {
	app.Get("/image/theme-color", image_controllers.GetThemeColor)
	app.Post("/image/manual-upload", image_controllers.ManualImageUpload)
}
