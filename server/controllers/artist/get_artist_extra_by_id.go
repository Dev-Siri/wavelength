package artist_controllers

import (
	"wavelength/api"
	"wavelength/models"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
)

func GetArtistExtraById(ctx *fiber.Ctx) error {
	id := ctx.Params("id")

	response, err := api.YouTubeV3Client.Channels.List([]string{"snippet", "brandingSettings"}).Id(id).Do()

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get extra artist details from YouTube: "+err.Error())
	}

	return ctx.JSON(responses.Success[models.ArtistExtra]{
		Success: true,
		Data: models.ArtistExtra{
			Thumbnail: response.Items[0].Snippet.Thumbnails.High.Url,
		},
	})
}
