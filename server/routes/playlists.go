package routes

import (
	playlist_controllers "wavelength/controllers/playlist"

	"github.com/gofiber/fiber/v2"
)

func registerPlaylistRoutes(app *fiber.App) {
	app.Get("/playlists", playlist_controllers.GetPublicPlaylists)
	app.Get("/playlists/user/:email", playlist_controllers.GetUserPlaylists)
}
