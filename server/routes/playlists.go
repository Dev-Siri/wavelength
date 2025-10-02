package routes

import (
	playlist_controllers "wavelength/controllers/playlist"

	"github.com/gofiber/fiber/v2"
)

func registerPlaylistRoutes(app *fiber.App) {
	app.Get("/playlists", playlist_controllers.GetPublicPlaylists)
	app.Get("/playlists/user/:email", playlist_controllers.GetUserPlaylists)
	app.Get("/playlists/playlist/:playlistId", playlist_controllers.GetPlaylistById)
	app.Get("/playlists/playlist/:playlistId/length", playlist_controllers.GetPlaylistTracksLength)
	app.Get("/playlists/playlist/:playlistId/tracks", playlist_controllers.GetPlaylistTracks)
	app.Post("/playlists/user/:email", playlist_controllers.CreatePlaylist)
	app.Post("/playlists/playlist/:playlistId/tracks", playlist_controllers.AddRemovePlaylistTrack)
	app.Put("/playlists/playlist/:playlistId/tracks", playlist_controllers.RearrangePlaylistTracks)
	app.Patch("/playlists/playlist/:playlistId/visibility", playlist_controllers.ChangePlaylistVisibility)
}
