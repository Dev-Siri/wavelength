package music_controllers

import (
	"wavelength/services/gateway/api"
	"wavelength/services/gateway/models"

	"github.com/gofiber/fiber/v2"
)

func GetQuickPicks(ctx *fiber.Ctx) error {
	regionCode := ctx.Query("regionCode")

	quickPicks, err := api.YouTubeClient.GetQuickPicks(regionCode)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "An error occured while retrieving for your feed: "+err.Error())
	}

	if quickPicks.Error {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get your recommended feed.")
	}

	return ctx.JSON(models.Success(quickPicks.Results))
}
