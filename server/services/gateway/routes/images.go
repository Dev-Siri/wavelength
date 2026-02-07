package routes

import (
	image_controllers "wavelength/services/gateway/controllers/image"

	"github.com/gofiber/fiber/v2"
)

func registerImageRoutes(app *fiber.App) {
	images := app.Group("/image")

	images.Get("/theme-color", image_controllers.GetThemeColor)
	images.Post("/manual-upload", image_controllers.ManualImageUpload)
}
