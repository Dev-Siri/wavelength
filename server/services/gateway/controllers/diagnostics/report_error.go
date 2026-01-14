package diagnostics_controllers

import (
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func ReportError(ctx *fiber.Ctx) error {
	var applicationDiagnostic models.ApplicationDiagnostic

	if err := ctx.BodyParser(&applicationDiagnostic); err != nil {
		logging.Logger.Error("Could not parse request body as an application diagnostic object.", zap.Error(err))
		return fiber.NewError(fiber.StatusBadRequest, "Could not parse request body as an application diagnostic object.")
	}

	logging.Logger.Error("Client-side application reported an error",
		zap.String("error", applicationDiagnostic.Error),
		zap.String("source", applicationDiagnostic.Source),
		zap.String("platform", applicationDiagnostic.Platform),
	)

	ctx.Status(fiber.StatusNoContent)
	return nil
}
