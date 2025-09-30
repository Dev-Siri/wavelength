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

// PlayerRequest is the minimal shape we need for the youtubei player API.
type PlayerRequest struct {
	Context struct {
		Client struct {
			ClientName    string `json:"clientName"`
			ClientVersion string `json:"clientVersion"`
			Hl            string `json:"hl,omitempty"`
			TimeZone      string `json:"timeZone,omitempty"`
			Gl            string `json:"gl,omitempty"`
			UtcOffsetMin  int    `json:"utcOffsetMinutes,omitempty"`
		} `json:"client"`
	} `json:"context"`

	// Ask YouTube to mark content checks ok (used by some clients)
	ContentCheckOk bool `json:"contentCheckOk,omitempty"`
	RacyCheckOk    bool `json:"racyCheckOk,omitempty"`

	// Either "videoId" or "playbackContext" can be used depending on what you want.
	VideoID string `json:"videoId,omitempty"`
}

// Example minimal response subset for checking playabilityStatus
type PlayerResponse struct {
	PlayabilityStatus struct {
		Status      string `json:"status"`
		Reason      string `json:"reason,omitempty"`
		ErrorScreen any    `json:"errorScreen,omitempty"`
		Embeddable  bool   `json:"embeddable,omitempty"`
		AllowEmbed  bool   `json:"allowEmbed,omitempty"`
		Miniplayer  any    `json:"miniplayer,omitempty"`
		// ... lots more fields exist; parse as needed
	} `json:"playabilityStatus"`
	StreamingData any `json:"streamingData,omitempty"`
	VideoDetails  any `json:"videoDetails,omitempty"`
}

// headerRoundTripper injects headers per request.
type headerRoundTripper struct {
	base http.RoundTripper
}

func (h *headerRoundTripper) RoundTrip(req *http.Request) (*http.Response, error) {
	// TV-like UA (Apple TV / TVHTML5) — tweak versions if needed
	req.Header.Set("User-Agent", "Mozilla/5.0 (AppleTV; U; CPU OS 14_0 like Mac OS X; en-us) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15")
	req.Header.Set("X-YouTube-Client-Name", "TVHTML5")
	req.Header.Set("X-YouTube-Client-Version", "7.20240724.13.00") // example version
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Origin", "https://www.youtube.com")
	req.Header.Set("Referer", "https://www.youtube.com/")
	req.Header.Set("Sec-Fetch-Mode", "navigate")
	// any additional headers can be set here
	return h.base.RoundTrip(req)
}

// buildHTTPClient creates an http.Client with cookiejar and header injector
func buildHTTPClient() (*http.Client, error) {
	client := &http.Client{
		Timeout: 20 * time.Second,
		Transport: &headerRoundTripper{
			base: http.DefaultTransport,
		},
	}
	return client, nil
}
