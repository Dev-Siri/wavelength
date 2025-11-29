package playlist_controllers

import (
	"html"
	"wavelength/db"
	"wavelength/models"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
)

func GetPlaylistTracks(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")

	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
	}

	rows, err := db.Database.Query(`
		SELECT
			playlist_track_id,
			title,
			thumbnail,
			position_in_playlist,
			is_explicit,
			author,
			duration,
			video_id,
			video_type,
			playlist_id
		FROM playlist_tracks
		WHERE playlist_id = $1
	`, playlistId)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get playlist tracks: "+err.Error())
	}

	playlistTracks := make([]models.PlaylistTrack, 0)

	for rows.Next() {
		var playlistTrack models.PlaylistTrack

		if err := rows.Scan(
			&playlistTrack.PlaylistTrackId,
			&playlistTrack.Title,
			&playlistTrack.Thumbnail,
			&playlistTrack.PositionInPlaylist,
			&playlistTrack.IsExplicit,
			&playlistTrack.Author,
			&playlistTrack.Duration,
			&playlistTrack.VideoId,
			&playlistTrack.VideoType,
			&playlistTrack.PlaylistId,
		); err != nil {
			return fiber.NewError(fiber.StatusInternalServerError, "Failed to get playlist tracks: "+err.Error())
		}

		playlistTrack.Title = html.UnescapeString(playlistTrack.Title)

		playlistTracks = append(playlistTracks, playlistTrack)
	}

	return ctx.JSON(responses.Success(playlistTracks))
}
