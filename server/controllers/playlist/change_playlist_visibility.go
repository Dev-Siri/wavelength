package playlist_controllers

import (
	"wavelength/db"
	"wavelength/models"

	"github.com/gofiber/fiber/v2"
)

func ChangePlaylistVisibility(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	playlistId := ctx.Params("playlistId")

	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
	}

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
		return fiber.NewError(fiber.StatusUnauthorized, "Visibility change cannot be performed because the authorized user is not the author of the playlist.")
	}

	rows, err := db.Database.Query(`
		SELECT is_public FROM playlists
		WHERE playlist_id = $1;
	`, playlistId)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to change visibility of playlist: "+err.Error())
	}

	var isPublic bool

	for rows.Next() {
		if err := rows.Scan(&isPublic); err != nil {
			return fiber.NewError(fiber.StatusInternalServerError, "Failed to change visibility of playlist: "+err.Error())
		}
	}

	_, err = db.Database.Exec(`
		UPDATE playlists
		SET is_public = $1
		WHERE playlist_id = $2;
	`, !isPublic, playlistId)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to change visibility of playlist: "+err.Error())
	}

	var changedVisibility string

	if isPublic {
		changedVisibility = "private"
	} else {
		changedVisibility = "public"
	}

	return ctx.JSON(models.Success("Visibility of playlist with ID " + playlistId + " changed to " + changedVisibility))
}
