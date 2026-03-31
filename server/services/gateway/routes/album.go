package routes

import (
	album_controllers "github.com/Dev-Siri/wavelength/server/services/gateway/controllers/album"
	"github.com/Dev-Siri/wavelength/server/shared/middleware"

	"github.com/gofiber/fiber/v2"
)

func registerAlbumRoutes(app *fiber.App) {
	albums := app.Group("/albums")

	albums.Get("/search", album_controllers.SearchAlbums)
	albums.Get("/album/:albumId", album_controllers.GetAlbumDetails)
	albums.Get("/saves", middleware.JwtAuthMiddleware, album_controllers.GetSavedAlbums)
	albums.Post("/album/:albumId/save", middleware.JwtAuthMiddleware, album_controllers.SaveAlbum)
	albums.Get("/album/:albumId/is-saved", middleware.JwtAuthMiddleware, album_controllers.IsAlbumSaved)
	albums.Get("/album/:albumId/is-lossless", album_controllers.GetIsAlbumLossless)
	albums.Get("/album/:albumId/:videoId/cover", album_controllers.GetAlbumLiveCover)
}
