package playlist_controllers

import (
	"wavelength/services/gateway/db"
	"wavelength/services/gateway/models"
	"wavelength/services/gateway/models/schemas"

	"github.com/gofiber/fiber/v2"
)

func RearrangePlaylistTracks(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")

	var updates []schemas.TrackPositionUpdateSchema

	if err := ctx.BodyParser(&updates); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "Invalid JSON body: "+err.Error())
	}

	if len(updates) == 0 {
		return fiber.NewError(fiber.StatusBadRequest, "No positions provided.")
	}

	tx, err := db.Database.Begin()

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to start transaction: "+err.Error())
	}

	defer tx.Rollback()

	stmt, err := tx.Prepare(`
		UPDATE playlist_tracks
		SET position_in_playlist = $1
		WHERE playlist_id = $2 AND playlist_track_id = $3
	`)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to prepare statement: "+err.Error())
	}

	defer stmt.Close()

	for _, pos := range updates {
		if _, err := stmt.Exec(pos.NewPos, playlistId, pos.PlaylistTrackId); err != nil {
			return fiber.NewError(fiber.StatusInternalServerError, "Failed to update playlist positions: "+err.Error())
		}
	}

	if err := tx.Commit(); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Transaction commit failed: "+err.Error())
	}

	return ctx.JSON(models.Success("Playlist positions updated successfully."))
}
