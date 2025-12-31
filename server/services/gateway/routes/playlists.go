package routes

import (
	playlist_controllers "wavelength/services/gateway/controllers/playlist"
	"wavelength/services/gateway/middleware"

	"github.com/gofiber/fiber/v2"
)

func registerPlaylistRoutes(app *fiber.App) {
	app.Get("/playlists", playlist_controllers.GetPublicPlaylists)
	app.Post("/playlists/user/:email", middleware.JwtAuthMiddleware, playlist_controllers.CreatePlaylist)
	app.Get("/playlists/user/:email", middleware.JwtAuthMiddleware, playlist_controllers.GetUserPlaylists)
	app.Get("/playlists/playlist/:playlistId", playlist_controllers.GetPlaylistById)
	app.Delete("/playlists/playlist/:playlistId", middleware.JwtAuthMiddleware, playlist_controllers.DeletePlaylistById)
	app.Put("/playlists/playlist/:playlistId", playlist_controllers.EditPlaylist)
	app.Get("/playlists/playlist/:playlistId/length", playlist_controllers.GetPlaylistTracksLength)
	app.Get("/playlists/playlist/:playlistId/tracks", playlist_controllers.GetPlaylistTracks)
	app.Post("/playlists/playlist/:playlistId/tracks", playlist_controllers.AddRemovePlaylistTrack)
	app.Put("/playlists/playlist/:playlistId/tracks", playlist_controllers.RearrangePlaylistTracks)
	app.Patch("/playlists/playlist/:playlistId/visibility", middleware.JwtAuthMiddleware, playlist_controllers.ChangePlaylistVisibility)
}
