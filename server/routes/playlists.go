package routes

import (
	playlist_controllers "wavelength/controllers/playlist"

	"github.com/gofiber/fiber/v2"
)

func registerPlaylistRoutes(app *fiber.App) {
	app.Get("/playlists", playlist_controllers.GetPublicPlaylists)
	app.Get("/playlists/user/:email", playlist_controllers.GetUserPlaylists)
	app.Post("/playlists/user/:email", playlist_controllers.CreatePlaylist)
	app.Patch("/playlists/playlist/:playlistId/visibility", playlist_controllers.ChangePlaylistVisibility)
}
