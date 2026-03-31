package routes

import (
	stream_controllers "github.com/Dev-Siri/wavelength/server/services/player/controllers/stream"
	"github.com/Dev-Siri/wavelength/server/shared/middleware"
	"github.com/gofiber/fiber/v2"
)

func registerStreamRoutes(app *fiber.App) {
	streams := app.Group("/streams")

	streams.Get("/:videoId", middleware.JwtAuthMiddleware, stream_controllers.GetStreamSource)
	streams.Get("/:videoId/playability-status", middleware.JwtAuthMiddleware, stream_controllers.GetStreamPlayabilityStatus)
	// Playback handler uses query-param based auth check to allow video players to directly play an URL.
	streams.Get("/playback/:token/:videoId/:part", stream_controllers.StreamPlayback)
}
