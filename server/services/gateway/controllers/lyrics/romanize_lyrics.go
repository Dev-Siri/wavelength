package lyrics_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/proto/lyricspb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func RomanizeLyrics(ctx *fiber.Ctx) error {
	var body struct {
		Lyrics []*commonpb.LyricsLine `json:"lyrics"`
	}
	if err := ctx.BodyParser(&body); err != nil {
		logging.Logger.Error("Body parse failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusUnprocessableEntity, "Body parse failed.")
	}

	romanizationResponse, err := clients.LyricClient.RomanizeLyrics(ctx.Context(), &lyricspb.RomanizeLyricsRequest{
		Lyrics: body.Lyrics,
	})
	if err != nil {
		logging.Logger.Error("LyricService: 'RomanizeLyrics' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Lyrics romanization failed.")
	}

	return shared_models.Success(ctx, romanizationResponse)
}
