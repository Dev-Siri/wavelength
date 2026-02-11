package routes

import (
	playlist_controllers "github.com/Dev-Siri/wavelength/server/services/gateway/controllers/playlist"
	"github.com/Dev-Siri/wavelength/server/services/gateway/middleware"

	"github.com/gofiber/fiber/v2"
)

func registerPlaylistRoutes(app *fiber.App) {
	playlists := app.Group("/playlists")

	playlists.Get("/", playlist_controllers.GetPublicPlaylists)
	playlists.Post("/user/:email", middleware.JwtAuthMiddleware, playlist_controllers.CreatePlaylist)
	playlists.Get("/user/:email", middleware.JwtAuthMiddleware, playlist_controllers.GetUserPlaylists)
	playlists.Get("/playlist/:playlistId", playlist_controllers.GetPlaylistById)
	playlists.Delete("/playlist/:playlistId", middleware.JwtAuthMiddleware, playlist_controllers.DeletePlaylistById)
	playlists.Put("/playlist/:playlistId", playlist_controllers.EditPlaylist)
	playlists.Get("/playlist/:playlistId/length", playlist_controllers.GetPlaylistTracksLength)
	playlists.Get("/playlist/:playlistId/tracks", playlist_controllers.GetPlaylistTracks)
	playlists.Post("/playlist/:playlistId/tracks", playlist_controllers.AddRemovePlaylistTrack)
	playlists.Put("/playlist/:playlistId/tracks", playlist_controllers.RearrangePlaylistTracks)
	playlists.Patch("/playlist/:playlistId/visibility", middleware.JwtAuthMiddleware, playlist_controllers.ChangePlaylistVisibility)
}
