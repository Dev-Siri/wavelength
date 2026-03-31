package spotify

import (
	"encoding/json"
	"errors"
	"net/http"

	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/google/uuid"
)

var MusicFetch = newMusicFetchClient()

type MusicFetchClient struct {
	httpClient http.Client
	host       string
}

type musicFetchService struct {
	ID   string `json:"id"`
	Link string `json:"link"`
}

type musicFetchImage struct {
	URL    string `json:"url"`
	Width  int    `json:"width"`
	Height int    `json:"height"`
}

type musicFetchSelectedServices struct {
	Tidal      musicFetchService `json:"tidal"`
	AppleMusic musicFetchService `json:"appleMusic"`
}

type musicFetchArtist struct {
	Type     string                     `json:"type"`
	Name     string                     `json:"name"`
	Services musicFetchSelectedServices `json:"services"`
}

type musicFetchAlbum struct {
	Type        string                     `json:"type"`
	Name        string                     `json:"name"`
	TotalTracks int                        `json:"totalTracks"`
	ReleaseDate string                     `json:"releaseDate"`
	Image       musicFetchImage            `json:"image"`
	Services    musicFetchSelectedServices `json:"services"`
}

type musicFetchResultResponse struct {
	Result struct {
		Type        string                     `json:"type"`
		Name        string                     `json:"name"`
		Duration    int                        `json:"duration"`
		ISRC        string                     `json:"isrc"`
		IsExplicit  bool                       `json:"isExplicit"`
		PreviewURL  string                     `json:"previewUrl"`
		ReleaseDate string                     `json:"releaseDate"`
		Image       musicFetchImage            `json:"image"`
		Copyright   string                     `json:"copyright"`
		Distributor string                     `json:"distributor"`
		Services    musicFetchSelectedServices `json:"services"`
		Artists     []musicFetchArtist         `json:"artists"`
		Albums      []musicFetchAlbum          `json:"albums"`
	} `json:"result"`
}

const musicFetchHost = "musicfetch2.p.rapidapi.com"

func newMusicFetchClient() *MusicFetchClient {
	client := http.Client{
		Transport: &spotifyTransport{apiHost: musicFetchHost},
	}

	return &MusicFetchClient{
		httpClient: client,
		host:       musicFetchHost,
	}
}

func (c *MusicFetchClient) LookupAppleMusicURLByISRC(isrc string) (string, error) {
	requestUrl := "https://" + c.host + "/isrc"
	request, err := http.NewRequest(http.MethodGet, requestUrl, nil)
	if err != nil {
		return "", err
	}

	queryParams := request.URL.Query()
	queryParams.Set("isrc", isrc)
	queryParams.Set("services", "appleMusic")
	queryParams.Set("country", "US")

	request.URL.RawQuery = queryParams.Encode()

	response, err := c.httpClient.Do(request)
	if err != nil {
		return "", err
	}

	defer response.Body.Close()

	if response.StatusCode < 200 ||
		response.StatusCode > 299 {
		return "", errors.New("HTTP response was unsuccessful.")
	}

	var musicFetchResponse musicFetchResultResponse
	if err := json.NewDecoder(response.Body).Decode(&musicFetchResponse); err != nil {
		return "", err
	}

	if musicFetchResponse.Result.Services.AppleMusic.Link == "" {
		return "", errors.New("Apple Music link returned was empty.")
	}

	return musicFetchResponse.Result.Services.AppleMusic.Link, nil
}

// Ensure Stream database initialization before call.
func (c *MusicFetchClient) FetchAppleMusicURL(albumID, isrc string) (string, error) {
	if shared_db.StreamDatabase == nil {
		return "", errors.New("Stream database not initialized.")
	}

	appleMusicURL, err := c.LookupAppleMusicURLByISRC(isrc)
	if err != nil {
		return "", err
	}

	appleMusicURLID := uuid.NewString()
	_, err = shared_db.StreamDatabase.Exec(`
		INSERT INTO "apple_music_urls" (
			apple_music_url_id,
			album_id,
			apple_music_url
		) VALUES ( $1, $2, $3 )
	`, appleMusicURLID, albumID, appleMusicURL)
	if err != nil {
		return "", err
	}

	return appleMusicURL, nil
}
