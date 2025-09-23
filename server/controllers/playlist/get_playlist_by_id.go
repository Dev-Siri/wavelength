package playlist_controllers

import (
	"wavelength/db"
	"wavelength/models"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
)

func GetPlaylistById(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")

	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
	}

	rows, err := db.Database.Query(`
		SELECT
			playlist_id,
			name,
			author_google_email,
			author_name,
			author_image,
			cover_image,
			is_public
		FROM playlists
		WHERE playlist_id = $1
		LIMIT 1;
	`, playlistId)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get playlist: "+err.Error())
	}

	var playlist *models.Playlist = nil

	for rows.Next() {
		playlist = &models.Playlist{}

		if err := rows.Scan(
			&playlist.PlaylistId,
			&playlist.Name,
			&playlist.AuthorGoogleEmail,
			&playlist.AuthorName,
			&playlist.AuthorImage,
			&playlist.CoverImage,
			&playlist.IsPublic,
		); err != nil {
			return fiber.NewError(fiber.StatusInternalServerError, "Failed to get playlist: "+err.Error())
		}
	}

	if playlist == nil {
		return fiber.NewError(fiber.StatusNotFound, "Playlist not found.")
	}

	return ctx.JSON(responses.Success[*models.Playlist]{
		Success: true,
		Data:    playlist,
	})
}
