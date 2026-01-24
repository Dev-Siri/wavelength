package music_controllers

import (
	"wavelength/proto/commonpb"
	"wavelength/proto/musicpb"
	"wavelength/services/gateway/clients"
	type_constants "wavelength/services/gateway/constants/types"
	"wavelength/services/gateway/models"
	"wavelength/services/gateway/models/schemas"
	"wavelength/services/gateway/validation"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func LikeTrack(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)
	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	// Versatile schema.
	var body schemas.PlaylistTrackAdditionSchema
	if err := ctx.BodyParser(&body); err != nil {
		logging.Logger.Error("Body read failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Body read failed.")
	}

	if !validation.IsPlaylistTrackAdditionShapeValid(body) {
		return fiber.NewError(fiber.StatusBadRequest, "Liked track to add isn't in proper shape.")
	}

	embeddedArtists := make([]*commonpb.EmbeddedArtist, len(body.Artists))
	for i, artist := range body.Artists {
		embeddedArtists[i] = &commonpb.EmbeddedArtist{
			Title:    artist.Title,
			BrowseId: artist.BrowseId,
		}
	}

	likedTracksResponse, err := clients.MusicClient.LikeTrack(ctx.Context(), &musicpb.LikeTrackRequest{
		Artists:    embeddedArtists,
		Thumbnail:  body.Thumbnail,
		Duration:   body.Duration,
		IsExplicit: body.IsExplicit,
		Title:      body.Title,
		VideoType:  type_constants.PlaylistTrackTypeGrpcMap[body.VideoType],
		VideoId:    body.VideoId,
		LikerEmail: authUser.Email,
	})
	if err != nil {
		logging.Logger.Error("MusicService: 'LikeTrack' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Like track failed.")
	}

	if likedTracksResponse.LikeType == musicpb.LikeTrackResponse_LIKE_TYPE_UNLIKE {
		return models.Success(ctx, "Track removed from likes.")
	}

	return models.Success(ctx, "Track saved to likes.")
}
