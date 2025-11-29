package playlist_controllers

import (
	"wavelength/db"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
)

func DeletePlaylistById(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")

	_, err := db.Database.Exec(`
		DELETE FROM playlists
		WHERE playlist_id = $1;
	`, playlistId)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to delete playlist: "+err.Error())
	}

	return ctx.JSON(responses.Success("Deleted playlist with ID " + playlistId))
}
