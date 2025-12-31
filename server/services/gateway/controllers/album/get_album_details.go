package album_controllers

import (
	"wavelength/services/gateway/api"
	"wavelength/services/gateway/models"

	"github.com/gofiber/fiber/v2"
)

func GetAlbumDetails(ctx *fiber.Ctx) error {
	albumId := ctx.Params("albumId")

	if albumId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Album ID is required for searching albums.")
	}

	searchResults, err := api.YouTubeClient.GetAlbumsDetails(albumId)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "An error occured while getting album details: "+err.Error())
	}

	return ctx.JSON(models.Success(searchResults))
}
