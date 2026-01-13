package artist_controllers

import (
	"encoding/json"
	"wavelength/proto/artistpb"
	"wavelength/services/gateway/models"
	"wavelength/services/gateway/models/schemas"
	"wavelength/services/gateway/validation"
	shared_clients "wavelength/shared/clients"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func FollowArtist(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	body := ctx.Body()
	var parsedBody schemas.ArtistFollowSchmea

	if err := json.Unmarshal(body, &parsedBody); err != nil {
		logging.Logger.Error("Body parse failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Body parse failed.")
	}

	if !validation.IsFollowArtistShapeValid(parsedBody) {
		return fiber.NewError(fiber.StatusInternalServerError, "Body is not in valid shape.")
	}

	_, err := shared_clients.ArtistClient.FollowArtist(ctx.Context(), &artistpb.FollowArtistRequest{
		FollowerEmail:   authUser.Email,
		ArtistName:      parsedBody.Name,
		ArtistThumbnail: parsedBody.Thumbnail,
		ArtistBrowseId:  parsedBody.BrowseId,
	})

	if err != nil {
		logging.Logger.Error("ArtistService: 'FollowArtist' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Artist follow failed. ")
	}

	return models.Success(ctx, "Successfully followed artist.")
}
