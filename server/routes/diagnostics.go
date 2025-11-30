package routes

import (
	diagnostics_handlers "wavelength/controllers/diagnostics"

	"github.com/gofiber/fiber/v2"
)

func registerDiagnosticsRoutes(app *fiber.App) {
	app.Get("/diagnostics/report-error", diagnostics_handlers.ReportError)
}
