package music_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetQuickPicks(ctx *fiber.Ctx) error {
	regionCode := ctx.Query("regionCode")

	quickPicksResponse, err := clients.MusicClient.GetQuickPicks(ctx.Context(), &musicpb.GetQuickPicksRequest{
		Gl: regionCode,
	})
	if err != nil {
		logging.Logger.Error("MusicServce: 'GetQuickPicks' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Quick picks fetch failed.")
	}

	return models.Success(ctx, quickPicksResponse)
}
