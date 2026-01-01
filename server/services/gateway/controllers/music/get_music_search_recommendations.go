package music_controllers

import (
	"strings"
	"wavelength/services/gateway/api"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetMusicSearchRecommendations(ctx *fiber.Ctx) error {
	query := ctx.Query("q")

	readyQuery := strings.ToLower(query)
	response, err := api.YouTubeClient.GetSearchResults(readyQuery)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get search recommendations: "+err.Error())
	}

	suggestedLinks := []models.SearchSuggestedLink{}

	for _, item := range response.Items {
		// YouTube returns "songs" and "albums" instead of "song" and "album"
		// Just a more accurate string for `type`.
		singularType := item.Type[:len(item.Type)-1]

		subtitleParts := strings.Split(item.Subtitle, " • ")

		if len(subtitleParts) < 3 {
			go logging.Logger.Error("Subtitle does not contain all parts (3)", zap.String("subtitle", item.Subtitle))
			// It's invalid, so we skip it here.
			continue
		}

		meta := models.SearchSuggestedLinkMeta{
			Type:                subtitleParts[0],
			AuthorOrAlbum:       subtitleParts[1],
			PlaysOrAlbumRelease: subtitleParts[2],
		}

		suggestedLink := models.SearchSuggestedLink{
			Meta:       meta,
			Title:      item.Title,
			Subtitle:   item.Subtitle,
			Thumbnail:  item.Thumbnail,
			BrowseId:   item.BrowseId,
			IsExplicit: item.IsExplicit,
			Type:       singularType,
		}

		suggestedLinks = append(suggestedLinks, suggestedLink)
	}

	return ctx.JSON(models.Success(models.SearchRecommendations{
		MatchingQueries: response.Query,
		MatchingLinks:   suggestedLinks,
	}))
}
