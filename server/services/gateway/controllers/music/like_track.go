package music_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models/schemas"
	"github.com/Dev-Siri/wavelength/server/services/gateway/validation"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	shared_type_constants "github.com/Dev-Siri/wavelength/server/shared/constants/types"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

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

	var embeddedAlbum *commonpb.EmbeddedAlbum
	if body.Album != nil {
		embeddedAlbum = &commonpb.EmbeddedAlbum{
			Title:    body.Album.Title,
			BrowseId: body.Album.BrowseId,
		}
	}

	likedTracksResponse, err := clients.MusicClient.LikeTrack(ctx.Context(), &musicpb.LikeTrackRequest{
		Artists:    embeddedArtists,
		Thumbnail:  body.Thumbnail,
		Duration:   body.Duration,
		IsExplicit: body.IsExplicit,
		Title:      body.Title,
		VideoType:  shared_type_constants.PlaylistTrackTypeGrpcMap[body.VideoType],
		VideoId:    body.VideoId,
		LikerEmail: authUser.Email,
		Album:      embeddedAlbum,
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
