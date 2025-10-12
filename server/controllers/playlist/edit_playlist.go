package playlist_controllers

import (
	"wavelength/db"
	"wavelength/models/responses"
	"wavelength/models/schemas"

	"github.com/gofiber/fiber/v2"
)

func EditPlaylist(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")

	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
	}

	var playlistEditBody schemas.PlaylistEditSchema

	if err := ctx.BodyParser(&playlistEditBody); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "Invalid JSON body: "+err.Error())
	}

	_, err := db.Database.Exec(`
		UPDATE playlists
		SET name = $1, cover_image = $2
		WHERE playlist_id = $3
	`, playlistEditBody.Name, playlistEditBody.CoverImage, playlistId)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to edit playlist: "+err.Error())
	}

	return ctx.JSON(responses.Success[string]{
		Success: true,
		Data:    "Edited playlist with ID " + playlistId + " successfully.",
	})
}
