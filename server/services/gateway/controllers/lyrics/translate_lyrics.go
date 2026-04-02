package lyrics_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/lyricspb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func TranslateLyrics(ctx *fiber.Ctx) error {
	var body struct {
		TextToTranslate []string `json:"textToTranslate"`
		Language        string   `json:"language"`
	}
	if err := ctx.BodyParser(&body); err != nil {
		logging.Logger.Error("Body parse failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusUnprocessableEntity, "Body parse failed.")
	}

	translateResponse, err := clients.LyricClient.TranslateLyrics(ctx.Context(), &lyricspb.TranslateLyricsRequest{
		TextToTranslate: body.TextToTranslate,
		Language:        body.Language,
	})
	if err != nil {
		logging.Logger.Error("LyricService: 'TranslateLyrics' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Lyrics translation failed.")
	}

	return shared_models.Success(ctx, translateResponse)
}
