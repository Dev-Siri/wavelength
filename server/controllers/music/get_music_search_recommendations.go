package music_controllers

import (
	"strings"
	"wavelength/api"
	"wavelength/models"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
)

func GetMusicSearchRecommendations(ctx *fiber.Ctx) error {
	query := ctx.Query("q")

	readyQuery := strings.ToLower(query)
	response, err := api.YouTubeClient.GetSearchResults(readyQuery)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get search recommendations: "+err.Error())
	}

	return ctx.JSON(responses.Success(models.SearchRecommendations{
		MatchingQueries: response.Query,
		MatchingLinks:   response.Items,
	}))
}
