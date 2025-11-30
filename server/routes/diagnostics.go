package routes

import (
	diagnostics_controllers "wavelength/controllers/diagnostics"

	"github.com/gofiber/fiber/v2"
)

func registerDiagnosticsRoutes(app *fiber.App) {
	app.Post("/diagnostics/report-error", diagnostics_controllers.ReportError)
}
