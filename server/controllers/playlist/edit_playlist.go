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

	// Build dynamic update query
	setClauses := []string{}
	args := []string{}
	argPos := 1

	if playlistEditBody.Name != "" {
		setClauses = append(setClauses, "name = $"+string(rune(argPos)))
		args = append(args, playlistEditBody.Name)
		argPos++
	}

	if playlistEditBody.CoverImage != "" {
		setClauses = append(setClauses, "cover_image = $"+string(rune(argPos)))
		args = append(args, playlistEditBody.CoverImage)
		argPos++
	}

	if len(setClauses) == 0 {
		return fiber.NewError(fiber.StatusBadRequest, "No fields provided for update.")
	}

	query := "UPDATE playlists SET " +
		func() string {
			s := ""
			for i, c := range setClauses {
				if i > 0 {
					s += ", "
				}
				s += c
			}
			return s
		}() +
		" WHERE playlist_id = $" + string(rune(argPos))

	args = append(args, playlistId)

	_, err := db.Database.Exec(query, args)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to edit playlist: "+err.Error())
	}

	return ctx.JSON(responses.Success[string]{
		Success: true,
		Data:    "Edited playlist with ID " + playlistId + " successfully.",
	})
}
