package music_controllers

import (
	"encoding/json"
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
	body := ctx.Body()
	// Versatile schema.
	var parsedBody schemas.PlaylistTrackAdditionSchema
	if err := json.Unmarshal(body, &parsedBody); err != nil {
		go logging.Logger.Error("Body read failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Body read failed.")
	}

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	if !validation.IsPlaylistTrackAdditionShapeValid(parsedBody) {
		return fiber.NewError(fiber.StatusBadRequest, "Liked track to add isn't in proper shape.")
	}

	var grpcVideoType commonpb.VideoType

	if parsedBody.VideoType == type_constants.PlaylistTrackTypeUVideo {
		grpcVideoType = commonpb.VideoType_VIDEO_TYPE_UVIDEO
	} else {
		grpcVideoType = commonpb.VideoType_VIDEO_TYPE_TRACK
	}

	embeddedArtists := make([]*commonpb.EmbeddedArtist, 0)
	for _, artist := range parsedBody.Artists {
		embeddedArtists = append(embeddedArtists, &commonpb.EmbeddedArtist{
			Title:    artist.Title,
			BrowseId: artist.BrowseId,
		})
	}
	likedTracksResponse, err := clients.MusicClient.LikeTrack(ctx.Context(), &musicpb.LikeTrackRequest{
		Artists:    embeddedArtists,
		Thumbnail:  parsedBody.Thumbnail,
		Duration:   parsedBody.Duration,
		IsExplicit: parsedBody.IsExplicit,
		Title:      parsedBody.Title,
		VideoType:  grpcVideoType,
		VideoId:    parsedBody.VideoId,
		LikerEmail: authUser.Email,
	})
	if err != nil {
		go logging.Logger.Error("MusicService: 'LikeTrack' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Like track failed.")
	}

	if likedTracksResponse.LikeType == musicpb.LikeTrackResponse_LIKE_TYPE_UNLIKE {
		return models.Success(ctx, "Track removed from likes.")
	}

	return models.Success(ctx, "Track saved to likes.")
}
