package routes

import (
	diagnostics_controllers "github.com/Dev-Siri/wavelength/server/services/gateway/controllers/diagnostics"

	"github.com/gofiber/fiber/v2"
)

func registerDiagnosticsRoutes(app *fiber.App) {
	app.Post("/diagnostics/report-error", diagnostics_controllers.ReportError)
}
