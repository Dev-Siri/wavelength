package stream_controllers

import (
	"strings"
	"wavelength/api"
	"wavelength/constants"

	"github.com/gofiber/fiber/v2"
	yt_streams "github.com/kkdai/youtube/v2"
)

/*
A "direct" route is almost the same as a normal stream getter, except that it has one key difference. Unlike the normal get_audio_stream route
that returns a JSON with that stream's URL, bitrate, ext, and duration, a "direct" route redirects you to the URL directly, almost like an
instant stream URL. This is mainly helpful in setting up streams on the WaveLength mobile app that can be preloaded by just_audio since they only
accept the URL and fetch it based on whenever they feel the need to. The normal route wouldn't work for requiring JSON parsing after fetch.
*/
func GetDirectAudioStream(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")

	video, err := api.YoutubeStreamClient.GetVideo(videoId)

	if err != nil {
		fiber.NewError(fiber.StatusInternalServerError, "Failed to get YouTube stream data: "+err.Error())
	}

	var mp4Format *yt_streams.Format = nil

	formats := video.Formats.WithAudioChannels()

	for _, format := range formats {
		if strings.Contains(format.MimeType, constants.SupportedStreamingFormat) {
			mp4Format = &format
		}
	}

	if mp4Format == nil {
		return fiber.NewError(fiber.StatusNotFound, "Cannot find any streams with the supported format. ("+constants.SupportedStreamingFormat+")")
	}

	return ctx.Redirect(mp4Format.URL)
}
