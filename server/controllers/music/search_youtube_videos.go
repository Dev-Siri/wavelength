package music_controllers

import (
	"html"
	"wavelength/api"
	"wavelength/models"
	"wavelength/models/responses"
	"wavelength/utils"

	"github.com/gofiber/fiber/v2"
)

func SearchYouTubeVideos(ctx *fiber.Ctx) error {
	query := ctx.Query("q")

	if query == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Query (q) is required for searching YouTube videos.")
	}

	searchResults, err := api.YouTubeV3Client.Search.List([]string{"snippet"}).Q(query).MaxResults(10).Do()

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "An error occured while searching for YouTube videos: "+err.Error())
	}

	if len(searchResults.Items) == 0 {
		return fiber.NewError(fiber.StatusNotFound, "No search results for that query.")
	}

	var youtubeVideos []models.YouTubeVideo

	for _, item := range searchResults.Items {
		video := models.YouTubeVideo{
			VideoId:   item.Id.VideoId,
			Title:     html.UnescapeString(item.Snippet.Title),
			Thumbnail: utils.GetHighestPossibleThumbnailUrl(item.Snippet.Thumbnails),
			Author:    item.Snippet.ChannelTitle,
		}

		youtubeVideos = append(youtubeVideos, video)
	}

	return ctx.JSON(responses.Success[[]models.YouTubeVideo]{
		Success: true,
		Data:    youtubeVideos,
	})
}
