package routes

import (
	artist_controllers "github.com/Dev-Siri/wavelength/server/services/gateway/controllers/artist"
	"github.com/Dev-Siri/wavelength/server/shared/middleware"

	"github.com/gofiber/fiber/v2"
)

func registerArtistRoutes(app *fiber.App) {
	artists := app.Group("/artists")

	artists.Get("/artist/:browseId", artist_controllers.GetArtistDetails)
	artists.Get("/search", artist_controllers.SearchArtists)
	artists.Get("/followed", middleware.JwtAuthMiddleware, artist_controllers.GetFollowedArtists)
	artists.Get("/followed/:browseId/is-following", middleware.JwtAuthMiddleware, artist_controllers.IsFollowingArtist)
	artists.Post("/followed", middleware.JwtAuthMiddleware, artist_controllers.FollowArtist)
}
