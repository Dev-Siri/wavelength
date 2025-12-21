package routes

import (
	album_controllers "wavelength/controllers/album"

	"github.com/gofiber/fiber/v2"
)

func registerAlbumRoutes(app *fiber.App) {
	app.Get("/albums/search", album_controllers.SearchAlbums)
	app.Get("/albums/album/:albumId", album_controllers.GetAlbumDetails)
}
