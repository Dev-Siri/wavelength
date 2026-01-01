package playlist_controllers

import (
	"encoding/json"
	"wavelength/proto/playlistpb"
	"wavelength/services/gateway/clients"
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

	body := ctx.Body()
	var parsedBody schemas.PlaylistTrackAdditionSchema

	if err := json.Unmarshal(body, &parsedBody); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to read body: "+err.Error())
	}

	if !validation.IsPlaylistTrackAdditionShapeValid(parsedBody) {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist track to add isn't in proper shape.")
	}

	var enumVideoType playlistpb.VideoType

	if parsedBody.VideoType == "uvideo" {
		enumVideoType = playlistpb.VideoType_UVIDEO
	} else {
		enumVideoType = playlistpb.VideoType_TRACK
	}

	toggleResponse, err := clients.PlaylistClient.AddRemovePlaylistTrack(ctx.Context(), &playlistpb.AddRemovePlaylistTrackRequest{
		Author:     parsedBody.Author,
		Thumbnail:  parsedBody.Thumbnail,
		Duration:   parsedBody.Duration,
		IsExplicit: parsedBody.IsExplicit,
		Title:      parsedBody.Title,
		VideoId:    parsedBody.VideoId,
		VideoType:  enumVideoType,
		PlaylistId: playlistId,
	})
	if err != nil {
		go logging.Logger.Error("PlaylistService: 'AddRemovePlaylistTrack' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlist track addition/removal failed.")
	}

	if toggleResponse.ToggleType == playlistpb.AddRemovePlaylistTrackResponse_REMOVE {
		return ctx.JSON(models.Success("Removed song from playlist successfully."))
	}

	return ctx.JSON(models.Success("Added song to playlist successfully."))
}
