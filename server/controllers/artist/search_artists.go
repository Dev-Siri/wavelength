package artist_controllers

import (
	"wavelength/api"
	api_models "wavelength/models/api"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
)

func SearchArtists(ctx *fiber.Ctx) error {
	query := ctx.Query("q")
	nextPageToken := ctx.Query("nextPageToken")

	if query == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Query (q) is required for searching artists.")
	}

	searchResults, err := api.YouTubeClient.SearchArtists(query, nextPageToken)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "An error occured while searching for artists: "+err.Error())
	}

	return ctx.JSON(responses.Success[*api_models.ArtistSearchResponse]{
		Success: true,
		Data:    searchResults,
	})
}
