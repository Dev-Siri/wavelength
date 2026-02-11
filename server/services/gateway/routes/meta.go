package routes

import (
	meta_controllers "github.com/Dev-Siri/wavelength/server/services/gateway/controllers/meta"

	"github.com/gofiber/fiber/v2"
)

func registerMetaRoutes(app *fiber.App) {
	app.Get("/meta/vstatus", meta_controllers.GetVersionStatus)
}
