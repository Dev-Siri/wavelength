package playlist_controllers

import (
	"database/sql"
	"encoding/json"
	"errors"
	"wavelength/db"
	"wavelength/models/responses"
	"wavelength/models/schemas"
	"wavelength/validation"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
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
	var songCount int
	err := db.Database.QueryRow(`
		SELECT COUNT(*) 
		FROM playlist_tracks 
		WHERE playlist_id = $1 AND video_id = $2`,
		playlistId, parsedBody.VideoId).Scan(&songCount)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to check existing track: "+err.Error())
	}

	if songCount > 0 {
		_, err := db.Database.Exec(`
			DELETE FROM playlist_tracks 
			WHERE playlist_id = $1 AND video_id = $2
		`, playlistId, parsedBody.VideoId)

		if err != nil {
			return fiber.NewError(fiber.StatusInternalServerError, "Failed to remove track: "+err.Error())
		}

		return ctx.JSON(responses.Success("Removed song from playlist successfully."))
	}

	var totalSongCount int
	err = db.Database.QueryRow(`
		SELECT COUNT(*) 
		FROM playlist_tracks 
		WHERE playlist_id = $1`,
		playlistId).Scan(&totalSongCount)

	if err != nil && !errors.Is(err, sql.ErrNoRows) {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to count playlist tracks: "+err.Error())
	}

	playlistTrackId := uuid.NewString()

	_, err = db.Database.Exec(`
		INSERT INTO playlist_tracks (
			title,
			thumbnail,
			duration,
			is_explicit,
			author,
			video_id,
			video_type,
			playlist_id, 
			playlist_track_id, 
			position_in_playlist
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
		parsedBody.Title,
		parsedBody.Thumbnail,
		parsedBody.Duration,
		parsedBody.IsExplicit,
		parsedBody.Author,
		parsedBody.VideoId,
		parsedBody.VideoType,
		playlistId, playlistTrackId, totalSongCount+1,
	)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to add track: "+err.Error())
	}

	return ctx.JSON(responses.Success("Added song to playlist successfully."))
}
