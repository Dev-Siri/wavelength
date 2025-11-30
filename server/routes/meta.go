package routes

import (
	meta_controllers "wavelength/controllers/meta"

	"github.com/gofiber/fiber/v2"
)

func registerMetaRoutes(app *fiber.App) {
	app.Get("/meta/vstatus", meta_controllers.GetVersionStatus)
}
