package music_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

const defaultIp = "127.0.0.1"

func GetQuickPicks(ctx *fiber.Ctx) error {
	regionCode := ctx.Query("regionCode")
	ip := ctx.IP()

	if ip == "" {
		ip = defaultIp
	}

	quickPicksResponse, err := clients.MusicClient.GetQuickPicks(ctx.Context(), &musicpb.GetQuickPicksRequest{
		Gl: regionCode,
		Ip: ip,
	})
	if err != nil {
		logging.Logger.Error("MusicServce: 'GetQuickPicks' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Quick picks fetch failed.")
	}

	return models.Success(ctx, quickPicksResponse)
}
