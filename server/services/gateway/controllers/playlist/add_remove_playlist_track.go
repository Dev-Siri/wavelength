package playlist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models/schemas"
	"github.com/Dev-Siri/wavelength/server/services/gateway/validation"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	shared_type_constants "github.com/Dev-Siri/wavelength/server/shared/constants/types"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

// POST handler, but actually also can perform a sort of DELETE.
// if (song in playlist): then remove it from playlist,
// else: add it to playlist
func AddRemovePlaylistTrack(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")

	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
	}

	var body schemas.PlaylistTrackAdditionSchema

	if err := ctx.BodyParser(&body); err != nil {
		logging.Logger.Error("Body read failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Body read failed.")
	}

	if !validation.IsPlaylistTrackAdditionShapeValid(body) {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist track to add isn't in proper shape.")
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

	toggleResponse, err := clients.PlaylistClient.AddRemovePlaylistTrack(ctx.Context(), &playlistpb.AddRemovePlaylistTrackRequest{
		Artists:    embeddedArtists,
		Thumbnail:  body.Thumbnail,
		Duration:   body.Duration,
		IsExplicit: body.IsExplicit,
		Title:      body.Title,
		VideoId:    body.VideoId,
		VideoType:  shared_type_constants.PlaylistTrackTypeGrpcMap[body.VideoType],
		PlaylistId: playlistId,
		Album:      embeddedAlbum,
	})
	if err != nil {
		logging.Logger.Error("PlaylistService: 'AddRemovePlaylistTrack' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlist track addition/removal failed.")
	}

	if toggleResponse.ToggleType == playlistpb.AddRemovePlaylistTrackResponse_PLAYLIST_TRACK_TOGGLE_TYPE_REMOVE {
		return models.Success(ctx, "Removed song from playlist successfully.")
	}

	return models.Success(ctx, "Added song to playlist successfully.")
}
