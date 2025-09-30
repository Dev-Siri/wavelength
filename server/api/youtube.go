package api

import (
	"context"

	api_interface "wavelength/api/interface"

	yt_streams "github.com/kkdai/youtube/v2"
	"google.golang.org/api/option"
	"google.golang.org/api/youtube/v3"
)

var YouTubeClient *api_interface.YouTubeMusicClient
var YouTubeV3Client *youtube.Service
var YouTubeStreamClient *yt_streams.Client

func InitializeYouTubeClients(apiKey string) error {
	YouTubeStreamClient = &yt_streams.Client{}
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
