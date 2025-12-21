package album_controllers

import (
	"wavelength/api"
	"wavelength/models"

	"github.com/gofiber/fiber/v2"
)

func SearchAlbums(ctx *fiber.Ctx) error {
	query := ctx.Query("q")
	nextPageToken := ctx.Query("nextPageToken")

	if query == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Query (q) is required for searching albums.")
	}

	searchResults, err := api.YouTubeClient.SearchAlbums(query, nextPageToken)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "An error occured while searching for albums: "+err.Error())
	}

	return ctx.JSON(models.Success(searchResults))
}
