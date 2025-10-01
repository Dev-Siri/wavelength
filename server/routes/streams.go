package routes

import (
	stream_controllers "wavelength/controllers/streams"

	"github.com/gofiber/fiber/v2"
)

func registerStreamRoutes(app *fiber.App) {
	app.Get("/stream/url/:videoId/audio", stream_controllers.GetAudioUrl)
	app.Get("/stream/playback/:videoId/audio", stream_controllers.GetAudioStream)
	app.Get("/stream/playback/:videoId/video", stream_controllers.GetVideoStream)
}
