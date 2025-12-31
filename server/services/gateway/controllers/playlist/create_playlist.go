package playlist_controllers

import (
	"wavelength/services/gateway/db"
	"wavelength/services/gateway/models"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

func CreatePlaylist(ctx *fiber.Ctx) error {
	email := ctx.Params("email")
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	if email == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Email is required.")
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
	`, playlistId, "New Playlist", email, authUser.DisplayName, authUser.PhotoUrl, nil)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to create new playlist for user: "+err.Error())
	}

	return ctx.JSON(models.Success("Created new playlist for " + email))
}
