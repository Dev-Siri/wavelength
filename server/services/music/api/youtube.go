package api

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/services/music/env"

	"google.golang.org/api/option"
	"google.golang.org/api/youtube/v3"
)

var YouTubeV3Client *youtube.Service

func InitializeYouTubeV3Client() error {
	apiKey, err := env.GetGoogleApiKey()
	if err != nil {
		return err
	}

	ctx := context.Background()
	apiKeyOption := option.WithAPIKey(apiKey)
	service, err := youtube.NewService(ctx, apiKeyOption)
	if err != nil {
		return err
	}

	YouTubeV3Client = service
	return nil
}
