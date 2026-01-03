package music_controllers

import (
	"wavelength/services/gateway/api"
	"wavelength/services/gateway/models"

	"github.com/gofiber/fiber/v2"
)

func SearchMusicTracks(ctx *fiber.Ctx) error {
	query := ctx.Query("q")
	nextPageToken := ctx.Query("nextPageToken")

	if query == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Query (q) is required for searching music.")
	}

	searchResults, err := api.YouTubeClient.SearchMusicTracks(query, nextPageToken)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "An error occured while searching for tracks: "+err.Error())
	}

	return models.Success(ctx, searchResults)
}
