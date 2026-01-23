package playlist_controllers

import (
	"wavelength/proto/playlistpb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/services/gateway/models/schemas"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func RearrangePlaylistTracks(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")

	var updates []schemas.TrackPositionUpdateSchema

	if err := ctx.BodyParser(&updates); err != nil {
		logging.Logger.Error("Invalid JSON body.", zap.Error(err))
		return fiber.NewError(fiber.StatusBadRequest, "Invalid JSON body.")
	}

	if len(updates) == 0 {
		return fiber.NewError(fiber.StatusBadRequest, "No positions provided.")
	}

	grpcUpdates := make([]*playlistpb.RearrangePlaylistTracksRequest_PlaylistTrackPosUpdate, 0)
	for _, update := range updates {
		grpcUpdate := playlistpb.RearrangePlaylistTracksRequest_PlaylistTrackPosUpdate{
			PlaylistTrackId: update.PlaylistTrackId,
			NewPos:          uint32(update.NewPos),
		}

		grpcUpdates = append(grpcUpdates, &grpcUpdate)
	}

	_, err := clients.PlaylistClient.RearrangePlaylistTracks(ctx.Context(), &playlistpb.RearrangePlaylistTracksRequest{
		PlaylistId: playlistId,
		Updates:    grpcUpdates,
	})
	if err != nil {
		logging.Logger.Error("PlaylistService: 'RearrangePlaylistTracks' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlist rearrangement failed.")
	}

	return models.Success(ctx, "Playlist positions updated successfully.")
}
