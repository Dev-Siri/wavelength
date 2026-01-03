package music_controllers

import (
	"strings"
	"wavelength/proto/musicpb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

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
		go logging.Logger.Error("MusicService: 'GetMusicSearchSuggestions' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Search results fetch failed.")
	}

	return models.Success(ctx, searchResultsResponse)
}
