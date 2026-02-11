package routes

import (
	album_controllers "github.com/Dev-Siri/wavelength/server/services/gateway/controllers/album"

	"github.com/gofiber/fiber/v2"
)

func registerAlbumRoutes(app *fiber.App) {
	albums := app.Group("/albums")

	albums.Get("/search", album_controllers.SearchAlbums)
	albums.Get("/album/:albumId", album_controllers.GetAlbumDetails)
}
