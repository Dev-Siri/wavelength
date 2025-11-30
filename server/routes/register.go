package routes

import "github.com/gofiber/fiber/v2"

func RegisterRoutes(app *fiber.App) {
	registerArtistRoutes(app)
	registerImageRoutes(app)
	registerMusicRoutes(app)
	registerRegionRoutes(app)
	registerPlaylistRoutes(app)
	registerMetaRoutes(app)
}
