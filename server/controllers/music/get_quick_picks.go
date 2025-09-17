package music_controllers

import (
	"wavelength/api"
	api_models "wavelength/models/api"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
)

func GetQuickPicks(ctx *fiber.Ctx) error {
	regionCode := ctx.Query("regionCode")

	quickPicks, err := api.YouTubeClient.GetQuickPicks(regionCode)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "An error occured while retrieving for your feed.")
	}

	if quickPicks.Error {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get your recommended feed.")
	}

	return ctx.JSON(responses.Success[[]api_models.BaseMusicTrack]{
		Success: true,
		Data:    quickPicks.Results,
	})
}
