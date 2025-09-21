package music_controllers

import (
	"wavelength/api"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
	"google.golang.org/api/youtube/v3"
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

	data := searchResults.Items

	if len(data) == 0 {
		return fiber.NewError(fiber.StatusNotFound, "No search results for that query.")
	}

	return ctx.JSON(responses.Success[[]*youtube.SearchResult]{
		Success: true,
		Data:    data,
	})
}
