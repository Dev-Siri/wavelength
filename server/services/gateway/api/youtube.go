package api

import (
	"context"

	api_interface "wavelength/services/gateway/api/interface"

	"google.golang.org/api/option"
	"google.golang.org/api/youtube/v3"
)

var YouTubeClient *api_interface.YouTubeMusicClient
var YouTubeV3Client *youtube.Service

func InitializeYouTubeClients(apiKey string) error {
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
