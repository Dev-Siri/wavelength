package playlist_controllers

import (
	"wavelength/db"
	"wavelength/models"

	"github.com/gofiber/fiber/v2"
)

func DeletePlaylistById(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	playlistId := ctx.Params("playlistId")

	row := db.Database.QueryRow(`
		SELECT author_google_email FROM playlists
		WHERE playlist_id = $1
		LIMIT 1;
	`, playlistId)

	var playlistActualAuthorEmail string

	if err := row.Scan(&playlistActualAuthorEmail); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to scan database row: "+err.Error())
	}

	if playlistActualAuthorEmail != authUser.Email {
		return fiber.NewError(fiber.StatusUnauthorized, "Deletion operation cannot be performed because the authorized user is not the author of the playlist.")
	}

	_, err := db.Database.Exec(`
		DELETE FROM playlists
		WHERE playlist_id = $1;
	`, playlistId)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to delete playlist: "+err.Error())
	}

	return ctx.JSON(models.Success("Deleted playlist with ID " + playlistId))
}
