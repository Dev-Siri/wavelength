package playlist_controllers

import (
	"wavelength/db"
	"wavelength/models"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
)

func GetPublicPlaylists(ctx *fiber.Ctx) error {
	query := ctx.Query("q")

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
		WHERE name ILIKE $1
		AND is_public = true 
		LIMIT 10;
	`, "%"+query+"%")

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get public playlists: "+err.Error())
	}

	var playlists []models.Playlist

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
			return fiber.NewError(fiber.StatusInternalServerError, "Failed to get public playlists: "+err.Error())
		}

		playlists = append(playlists, playlist)
	}

	return ctx.JSON(responses.Success[[]models.Playlist]{
		Success: true,
		Data:    playlists,
	})
}
