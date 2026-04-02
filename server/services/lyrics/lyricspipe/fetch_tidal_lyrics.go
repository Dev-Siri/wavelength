package lyricspipe

import (
	"encoding/json"
	"net/http"
	"net/url"
	"strings"
)

type tidalSearchData struct {
	Data struct {
		Items []struct {
			ID   string `json:"id"`
			ISRC string `json:"isrc"`
		} `json:"items"`
	} `json:"data"`
}

type tidalLyricsData struct {
	Lyrics struct {
		Subtitles      string `json:"subtitles"`
		LyricsProvider string `json:"lyricsProvider"`
	} `json:"lyrics"`
}

func fetchLyricsFromTidal(
	title, artist string, isrc *string,
) ([]YouLyPlusLyricsResult, error) {
	serversToTry := shuffleAndPick(tidalServers, 2)
	for _, base := range serversToTry {
		var normalizedBase string
		if after, ok := strings.CutPrefix(base, "/"); ok {
			normalizedBase = after
		} else {
			normalizedBase = base
		}

		searchQuery := title + " " + artist
		searchParams := make(url.Values)

		searchParams.Set("s", searchQuery)

		searchResponse, err := http.NewRequest(http.MethodGet, normalizedBase+"/search", nil)
		if err != nil {
			continue
		}

		searchResponse.URL.RawQuery = searchParams.Encode()
		response, err := http.DefaultClient.Do(searchResponse)
		if err != nil {
			continue
		}

		if response.StatusCode != http.StatusOK {
			continue
		}

		var searchData tidalSearchData
		if err := json.NewDecoder(response.Body).Decode(&searchData); err != nil {
			response.Body.Close()
			continue
		}

		if len(searchData.Data.Items) == 0 {
			response.Body.Close()
			continue
		}

		bestTrack := searchData.Data.Items[0]
		if isrc != nil {
		inner:
			for _, item := range searchData.Data.Items {
				if item.ISRC == *isrc {
					bestTrack = item
					break inner
				}
			}
		}

		trackID := bestTrack.ID
		if trackID == "" {
			response.Body.Close()
			continue
		}

		response.Body.Close()
		lyricsRequest, err := http.NewRequest(http.MethodGet, normalizedBase+"/lyrics", nil)
		if err != nil {
			continue
		}

		lyricsParams := make(url.Values)
		lyricsParams.Set("id", trackID)
		lyricsRequest.URL.RawQuery = lyricsParams.Encode()

		lyricsResponse, err := http.DefaultClient.Do(lyricsRequest)
		if err != nil {
			continue
		}

		if lyricsResponse.StatusCode != http.StatusOK {
			continue
		}

		var lyricsData tidalLyricsData
		if err := json.NewDecoder(lyricsResponse.Body).Decode(&lyricsData); err != nil {
			lyricsResponse.Body.Close()
			continue
		}

		subtitles := lyricsData.Lyrics.Subtitles
		if subtitles == "" {
			lyricsResponse.Body.Close()
			continue
		}

		lines, err := parseLrcSubtitles(subtitles)
		if err != nil {
			continue
		}

		if len(lines) == 0 {
			continue
		}

		provider := "Tidal"
		if lyricsData.Lyrics.LyricsProvider != "" {
			provider = lyricsData.Lyrics.LyricsProvider
		}

		lyricsResponse.Body.Close()
		return []YouLyPlusLyricsResult{
			{
				Source: "Tidal (" + provider + ")",
				Lines:  lines,
			},
		}, nil
	}

	return nil, nil
}
