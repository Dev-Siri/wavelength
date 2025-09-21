package music_controllers

import (
	"fmt"
	"wavelength/api"
	"wavelength/models"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
	"github.com/sahilm/fuzzy"
)

// NOTE:
/*
  The "Music Video ID Route" is at best, a guesser. It can only try to accurately
  match the song name or artist name to get the actual music video. But there are many times it
  may not be accurate. So a wrong music video or even a short can get selected. Since YouTube doesn't provide any
  filters (music video, track or normal video) whatsoever for these use cases.
*/
func GetMusicVideoPreviewId(ctx *fiber.Ctx) error {
	songTitle := ctx.Query("title")
	artist := ctx.Query("artist")

	if songTitle == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Song Title (title) search param is required.")
	}

	if artist == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Artist (artist) search param is required.")
	}

	q := fmt.Sprintf("%s - %s official music video", artist, songTitle)
	response, err := api.YouTubeV3Client.Search.List([]string{"id", "snippet"}).
		Q(q).
		VideoCategoryId("10").
		MaxResults(10).
		Type("video").
		Order("viewCount").
		Do()

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get music video from YouTube: "+err.Error())
	}

	videos := []models.SearchableYouTubeVideo{}

	for _, item := range response.Items {
		videos = append(videos, models.SearchableYouTubeVideo{
			VideoID: item.Id.VideoId,
			Title:   item.Snippet.Title,
			Channel: item.Snippet.ChannelTitle,
		})
	}

	keyword := fmt.Sprintf("%s - %s official lyric video", artist, songTitle)
	titles := make([]string, len(videos))

	for i, v := range videos {
		titles[i] = v.Title + " " + v.Channel
	}

	matches := fuzzy.Find(keyword, titles)

	var selectedVideo models.SearchableYouTubeVideo

	if len(matches) > 0 {
		selectedVideo = videos[matches[0].Index]
	} else {
		// Fallback.
		selectedVideo = videos[0]
	}

	return ctx.JSON(responses.Success[models.MusicVideoPreviewId]{
		Success: true,
		Data:    models.MusicVideoPreviewId{VideoId: selectedVideo.VideoID},
	})
}
