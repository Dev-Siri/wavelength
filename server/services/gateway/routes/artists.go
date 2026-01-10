package routes

import (
	artist_controllers "wavelength/services/gateway/controllers/artist"
	"wavelength/services/gateway/middleware"

	"github.com/gofiber/fiber/v2"
)

func registerArtistRoutes(app *fiber.App) {
	app.Get("/artists/artist/:id", artist_controllers.GetArtistDetails)
	app.Get("/artists/search", artist_controllers.SearchArtists)
	app.Get("/artists/followed", middleware.JwtAuthMiddleware, artist_controllers.GetFollowedArtists)
	app.Get("/artists/followed/:browseId/is-following", middleware.JwtAuthMiddleware, artist_controllers.IsFollowingArtist)
	app.Post("/artists/followed", middleware.JwtAuthMiddleware, artist_controllers.FollowArtist)
}
