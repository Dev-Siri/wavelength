package artist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/artistpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models/schemas"
	"github.com/Dev-Siri/wavelength/server/services/gateway/validation"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func FollowArtist(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)
	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	var body schemas.ArtistFollowSchema
	if err := ctx.BodyParser(&body); err != nil {
		logging.Logger.Error("Body parse failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Body parse failed.")
	}

	if !validation.IsFollowArtistShapeValid(body) {
		return fiber.NewError(fiber.StatusInternalServerError, "Body is not in valid shape.")
	}

	_, err := clients.ArtistClient.FollowArtist(ctx.Context(), &artistpb.FollowArtistRequest{
		FollowerEmail:   authUser.Email,
		ArtistName:      body.Name,
		ArtistThumbnail: body.Thumbnail,
		ArtistBrowseId:  body.BrowseId,
	})

	if err != nil {
		logging.Logger.Error("ArtistService: 'FollowArtist' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Artist follow failed. ")
	}

	return models.Success(ctx, "Successfully followed artist.")
}
