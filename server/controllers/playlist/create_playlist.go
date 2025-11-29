package playlist_controllers

import (
	"wavelength/db"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

func CreatePlaylist(ctx *fiber.Ctx) error {
	email := ctx.Params("email")
	authorName := ctx.Query("authorName")
	authorImage := ctx.Query("authorImage")

	if email == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Email is required.")
	}

	if authorName == "" || authorImage == "" {
		return fiber.NewError(fiber.StatusUnauthorized, "Unauthorized.")
	}

	playlistId := uuid.NewString()

	_, err := db.Database.Exec(`
		INSERT INTO playlists (
			playlist_id,
			name,
			author_google_email,
			author_name,
			author_image,
			cover_image
		)
		VALUES ( $1, $2, $3, $4, $5, $6 );
	`, playlistId, "New Playlist", email, authorName, authorImage, nil)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to create new playlist for user: "+err.Error())
	}

	return ctx.JSON(responses.Success("Created new playlist for " + email))
}
