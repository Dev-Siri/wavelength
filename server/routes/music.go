package routes

import (
	music_controllers "wavelength/controllers/music"

	"github.com/gofiber/fiber/v2"
)

func registerMusicRoutes(app *fiber.App) {
	app.Get("/music/quick-picks", music_controllers.GetQuickPicks)
	app.Get("/music/:videoId/thumbnail", music_controllers.GetTrackThumbnail)
}
