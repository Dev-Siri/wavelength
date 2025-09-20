package music_controllers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"wavelength/api"
	"wavelength/constants"
	type_constants "wavelength/constants/types"
	"wavelength/env"
	api_models "wavelength/models/api"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
)

func GetTrackLyrics(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")

	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	matchedSongs, err := api.YouTubeClient.GetMatchedSong(videoId)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "No lyrics available: "+err.Error())
	}

	var spotifySong *api_models.SongMatch = nil

	for _, matchedSong := range matchedSongs {
		if matchedSong.Platform == type_constants.SongPlatformSpotify {
			spotifySong = &matchedSong
		}
	}

	if spotifySong == nil || spotifySong.UniqueId == nil {
		return fiber.NewError(fiber.StatusInternalServerError, "No lyrics available.")
	}

	spotifySongUniqueId := *spotifySong.UniqueId
	spotifySongIdParts := strings.Split(spotifySongUniqueId, "|")
	spotifyTrackId := spotifySongIdParts[len(spotifySongIdParts)-1]

	if spotifyTrackId == "" {
		return fiber.NewError(fiber.StatusInternalServerError, "No lyrics available.")
	}

	lyricsUrl := fmt.Sprintf("%s/v1/track/lyrics", constants.LyricsRapidApiUrl)
	request, err := http.NewRequest(http.MethodGet, lyricsUrl, nil)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get lyrics: "+err.Error())
	}

	rapidApiKey, _ := env.GetRapidApiKeys()
	lyricsRapidApiHost := env.GetLyricsRapidApiHost()

	request.Header.Set("X-RapidApi-Key", rapidApiKey)
	request.Header.Set("X-RapidApi-Host", lyricsRapidApiHost)

	queryParams := request.URL.Query()

	queryParams.Set("trackId", spotifyTrackId)
	queryParams.Set("format", "json")
	queryParams.Set("removeNote", "false")

	request.URL.RawQuery = queryParams.Encode()

	httpClient := &http.Client{}
	lyricsResponse, err := httpClient.Do(request)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get lyrics: "+err.Error())
	}

	defer lyricsResponse.Body.Close()

	var lyrics []api_models.Lyric

	if err := json.NewDecoder(lyricsResponse.Body).Decode(&lyrics); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get lyrics: "+err.Error())
	}

	return ctx.JSON(responses.Success[[]api_models.Lyric]{
		Success: true,
		Data:    lyrics,
	})
}
