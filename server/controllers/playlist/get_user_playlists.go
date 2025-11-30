package playlist_controllers

import (
	"wavelength/db"
	"wavelength/models"

	"github.com/gofiber/fiber/v2"
)

func GetUserPlaylists(ctx *fiber.Ctx) error {
	email := ctx.Params("email")

	if email == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Email is required.")
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
		WHERE author_google_email = $1
	`, email)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get playlists: "+err.Error())
	}

	playlists := make([]models.Playlist, 0)

	for rows.Next() {
		var playlist models.Playlist

		if err := rows.Scan(
			&playlist.PlaylistId,
			&playlist.Name,
			&playlist.AuthorGoogleEmail,
			&playlist.AuthorName,
			&playlist.AuthorImage,
			&playlist.CoverImage,
			&playlist.IsPublic,
		); err != nil {
			return fiber.NewError(fiber.StatusInternalServerError, "Failed to get playlists: "+err.Error())
		}

		playlists = append(playlists, playlist)
	}

	return ctx.JSON(models.Success(playlists))
}
