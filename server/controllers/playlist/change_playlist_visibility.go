package playlist_controllers

import (
	"wavelength/db"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
)

func ChangePlaylistVisibility(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")

	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
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

	return ctx.JSON(responses.Success[string]{
		Success: true,
		Data:    "Visibility of playlist with ID " + playlistId + " changed to " + changedVisibility,
	})
}
