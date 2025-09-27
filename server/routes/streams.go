package routes

import (
	stream_controllers "wavelength/controllers/streams"

	"github.com/gofiber/fiber/v2"
)

func registerStreamRoutes(app *fiber.App) {
	app.Get("/stream/playback/:videoId/audio", stream_controllers.GetAudioStream)
}
