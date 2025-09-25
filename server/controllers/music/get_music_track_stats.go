package music_controllers

import (
	"wavelength/api"
	"wavelength/models"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
)

func GetMusicTrackStats(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")

	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	response, err := api.YouTubeV3Client.Videos.List([]string{"statistics"}).Id(videoId).Do()

	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "Failed to get music track statistics from YouTube: "+err.Error())
	}

	stats := response.Items[0].Statistics

	return ctx.JSON(responses.Success[models.MusicTrackStats]{
		Success: true,
		Data: models.MusicTrackStats{
			Views:    stats.ViewCount,
			Likes:    stats.LikeCount,
			Comments: stats.CommentCount,
		},
	})
}
