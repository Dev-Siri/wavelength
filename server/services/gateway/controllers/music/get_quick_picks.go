package music_controllers

import (
	"wavelength/proto/musicpb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetQuickPicks(ctx *fiber.Ctx) error {
	regionCode := ctx.Query("regionCode")

	quickPicksResponse, err := clients.MusicClient.GetQuickPicks(ctx.Context(), &musicpb.GetQuickPicksRequest{
		Gl: regionCode,
	})
	if err != nil {
		go logging.Logger.Error("MusicServce: 'GetQuickPicks' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Quick picks fetch failed.")
	}

	return models.Success(ctx, quickPicksResponse)
}
