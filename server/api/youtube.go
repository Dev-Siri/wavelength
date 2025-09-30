package api

import (
	"context"
	"net/http"
	"time"

	api_interface "wavelength/api/interface"

	yt_streams "github.com/kkdai/youtube/v2"
	"google.golang.org/api/option"
	"google.golang.org/api/youtube/v3"
)

var YouTubeClient *api_interface.YouTubeMusicClient
var YouTubeV3Client *youtube.Service
var YoutubeStreamClient *yt_streams.Client

func InitializeYouTubeClients(apiKey string) error {
	customYouTubeStreamClient, err := buildHTTPClient()

	if err != nil {
		return err
	}

	YoutubeStreamClient = &yt_streams.Client{HTTPClient: customYouTubeStreamClient}
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

type headerRoundTripper struct {
	base http.RoundTripper
}

func (h *headerRoundTripper) RoundTrip(req *http.Request) (*http.Response, error) {
	req.Header.Set("User-Agent", "Mozilla/5.0 (AppleTV; U; CPU OS 14_0 like Mac OS X; en-us) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15")
	req.Header.Set("X-YouTube-Client-Name", "TVHTML5")
	req.Header.Set("X-YouTube-Client-Version", "7.20240724.13.00")
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Origin", "https://www.youtube.com")
	req.Header.Set("Referer", "https://www.youtube.com/")
	req.Header.Set("Sec-Fetch-Mode", "navigate")
	return h.base.RoundTrip(req)
}

func buildHTTPClient() (*http.Client, error) {
	client := &http.Client{
		Timeout: 20 * time.Second,
		Transport: &headerRoundTripper{
			base: http.DefaultTransport,
		},
	}
	return client, nil
}
