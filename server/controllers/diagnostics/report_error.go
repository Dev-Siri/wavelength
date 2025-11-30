package diagnostics_controllers

import (
	"encoding/json"
	"wavelength/logging"
	"wavelength/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func ReportError(ctx *fiber.Ctx) error {
	var applicationDiagnostic models.ApplicationDiagnostic

	if err := json.Unmarshal(ctx.Body(), &applicationDiagnostic); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "Could not parse request body as an application diagnostic object: "+err.Error())
	}

	logging.Logger.Error("Client-side application reported an error",
		zap.Any("diagnostic", applicationDiagnostic),
	)

	ctx.Status(fiber.StatusNoContent)
	return nil
}
