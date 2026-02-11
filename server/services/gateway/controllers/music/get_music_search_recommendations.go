package music_controllers

import (
	"strings"

	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetMusicSearchRecommendations(ctx *fiber.Ctx) error {
	query := ctx.Query("q")

	readyQuery := strings.ToLower(query)
	searchResultsResponse, err := clients.MusicClient.GetMusicSearchSuggestions(ctx.Context(), &musicpb.GetMusicSearchSuggestionsRequest{
		Query: readyQuery,
	})
	if err != nil {
		logging.Logger.Error("MusicService: 'GetMusicSearchSuggestions' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Search results fetch failed.")
	}

	return models.Success(ctx, searchResultsResponse)
}
