package artist_controllers

import (
	"wavelength/api"
	"wavelength/models"

	"github.com/gofiber/fiber/v2"
)

func GetArtistById(ctx *fiber.Ctx) error {
	id := ctx.Params("id")

	response, err := api.YouTubeClient.GetArtistDetails(id)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get artist details from YouTube: "+err.Error())
	}

	return ctx.JSON(models.Success(models.Artist{
		Title:           response.Title,
		Description:     response.Description,
		SubscriberCount: response.SubscriberCount,
		TopSongs:        response.TopSongs.Contents,
	}))
}
