package routes

import (
	lyrics_controllers "github.com/Dev-Siri/wavelength/server/services/gateway/controllers/lyrics"
	"github.com/gofiber/fiber/v2"
)

func registerLyricsRoutes(app *fiber.App) {
	lyrics := app.Group("/lyrics")

	lyrics.Get("/:videoId", lyrics_controllers.GetTrackLyrics)
	lyrics.Post("/romanize", lyrics_controllers.RomanizeLyrics)
	lyrics.Post("/translate", lyrics_controllers.TranslateLyrics)
}
