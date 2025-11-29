package artist_controllers

import (
	"wavelength/api"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
)

func GetArtistById(ctx *fiber.Ctx) error {
	id := ctx.Params("id")

	response, err := api.YouTubeClient.GetArtistDetails(id)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get artist details from YouTube: "+err.Error())
	}

	return ctx.JSON(responses.Success(response))
}
