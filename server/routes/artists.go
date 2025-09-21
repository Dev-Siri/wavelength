package routes

import (
	artist_controllers "wavelength/controllers/artist"

	"github.com/gofiber/fiber/v2"
)

func registerArtistRoutes(app *fiber.App) {
	app.Get("/artists/artist/:id/extra", artist_controllers.GetArtistExtraById)
	app.Get("/artists/artist/:id", artist_controllers.GetArtistById)
	app.Get("/artists/search", artist_controllers.SearchArtists)
}
