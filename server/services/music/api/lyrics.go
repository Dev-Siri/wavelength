package api

import (
	"encoding/json"
	"net/http"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/services/music/env"
)

var Lyrics *LyricsClient

type LyricsClient struct {
	httpClient http.Client
}

type lyricsTransport struct{}

type spotifyTrack struct {
	ID string `json:"id"`
}

type spotifyLyric struct {
	Text    string `json:"text"`
	StartMs int32  `json:"startMs"`
	DurMs   int32  `json:"durMs"`
}

func (t *lyricsTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	host, err := env.GetLyricsRapidApiHost()
	if err != nil {
		return nil, err
	}

	key, err := env.GetLyricsRapidApiKey()
	if err != nil {
		return nil, err
	}

	req.Header.Add("x-rapidapi-key", key)
	req.Header.Add("x-rapidapi-host", host)

	return http.DefaultTransport.RoundTrip(req)
}

func InitLyricsClient() {
	client := http.Client{Transport: &lyricsTransport{}}

	Lyrics = &LyricsClient{
		httpClient: client,
	}
}

func (c *LyricsClient) GetTrackSpotifyID(name, artist string) (string, error) {
	host, err := env.GetLyricsRapidApiHost()
	if err != nil {
		return "", err
	}

	requestUrl := "https://" + host + "/v1/track/search"
	request, err := http.NewRequest(http.MethodGet, requestUrl, nil)
	if err != nil {
		return "", err
	}

	queryParams := request.URL.Query()
	queryParams.Set("name", name+" "+artist)

	request.URL.RawQuery = queryParams.Encode()

	response, err := c.httpClient.Do(request)
	if err != nil {
		return "", err
	}

	defer response.Body.Close()

	var spotifyTrack *spotifyTrack
	if err := json.NewDecoder(response.Body).Decode(&spotifyTrack); err != nil {
		return "", err
	}

	return spotifyTrack.ID, nil
}

func (c *LyricsClient) GetTrackLyrics(spotifyTrackId string) ([]*commonpb.Lyric, error) {
	host, err := env.GetLyricsRapidApiHost()
	if err != nil {
		return nil, err
	}

	requestUrl := "https://" + host + "/v1/track/lyrics"
	request, err := http.NewRequest(http.MethodGet, requestUrl, nil)
	if err != nil {
		return nil, err
	}

	queryParams := request.URL.Query()
	queryParams.Set("trackId", spotifyTrackId)
	queryParams.Set("format", "json")
	queryParams.Set("removeNote", "false")

	request.URL.RawQuery = queryParams.Encode()

	response, err := c.httpClient.Do(request)
	if err != nil {
		return nil, err

	}

	defer response.Body.Close()

	var lyrics []spotifyLyric
	if err := json.NewDecoder(response.Body).Decode(&lyrics); err != nil {
		return nil, err
	}

	lyricsProto := make([]*commonpb.Lyric, len(lyrics))
	for i, lyric := range lyrics {
		lyricsProto[i] = &commonpb.Lyric{
			Text:    lyric.Text,
			StartMs: lyric.StartMs,
			DurMs:   lyric.DurMs,
		}
	}

	return lyricsProto, nil
}
