package routes

import (
	playlist_controllers "wavelength/controllers/playlist"

	"github.com/gofiber/fiber/v2"
)

func registerPlaylistRoutes(app *fiber.App) {
	app.Get("/playlists", playlist_controllers.GetPublicPlaylists)
	app.Get("/playlists/user/:email", playlist_controllers.GetUserPlaylists)
	app.Get("/playlists/playlist/:playlistId", playlist_controllers.GetPlaylistById)
	app.Post("/playlists/user/:email", playlist_controllers.CreatePlaylist)
	app.Get("/playlists/playlist/:playlistId/tracks", playlist_controllers.GetPlaylistTracks)
	app.Get("/playlists/playlist/:playlistId/length", playlist_controllers.GetPlaylistTracksLength)
	app.Patch("/playlists/playlist/:playlistId/visibility", playlist_controllers.ChangePlaylistVisibility)
}
