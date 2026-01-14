package playlist_controllers

import (
	"wavelength/proto/commonpb"
	"wavelength/proto/playlistpb"
	"wavelength/services/gateway/clients"
	type_constants "wavelength/services/gateway/constants/types"
	"wavelength/services/gateway/models"
	"wavelength/services/gateway/models/schemas"
	"wavelength/services/gateway/validation"
	"wavelength/shared/logging"

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
	for _, artist := range body.Artists {
		embeddedArtists = append(embeddedArtists, &commonpb.EmbeddedArtist{
			Title:    artist.Title,
			BrowseId: artist.BrowseId,
		})
	}

	toggleResponse, err := clients.PlaylistClient.AddRemovePlaylistTrack(ctx.Context(), &playlistpb.AddRemovePlaylistTrackRequest{
		Artists:    embeddedArtists,
		Thumbnail:  body.Thumbnail,
		Duration:   body.Duration,
		IsExplicit: body.IsExplicit,
		Title:      body.Title,
		VideoId:    body.VideoId,
		VideoType:  type_constants.PlaylistTrackTypeGrpcMap[body.VideoType],
		PlaylistId: playlistId,
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
