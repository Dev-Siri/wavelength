package api

import (
	"context"
	"net/http"
	"net/http/cookiejar"

	api_interface "wavelength/api/interface"
	"wavelength/env"
	"wavelength/utils"

	yt_streams "github.com/kkdai/youtube/v2"
	"google.golang.org/api/option"
	"google.golang.org/api/youtube/v3"
)

var YouTubeClient *api_interface.YouTubeMusicClient
var YouTubeStreamClient *yt_streams.Client
var YouTubeV3Client *youtube.Service

func InitializeYouTubeClients(apiKey string) error {
	cookieJar, err := cookiejar.New(nil)

	if err != nil {
		return err
	}

	if err := utils.LoadCookies(cookieJar, env.GetYtCookiePath()); err != nil {
		return err
	}

	YouTubeStreamClient = &yt_streams.Client{
		HTTPClient: &http.Client{Jar: cookieJar},
	}
	YouTubeClient = &api_interface.YouTubeMusicClient{}

	ctx := context.Background()
	apiKeyOption := option.WithAPIKey(apiKey)
	service, err := youtube.NewService(ctx, apiKeyOption)

	if err != nil {
		return err
	}

	YouTubeV3Client = service
	return nil
}
