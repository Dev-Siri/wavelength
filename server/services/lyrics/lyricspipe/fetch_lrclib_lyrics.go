package lyricspipe

import (
	"encoding/json"
	"errors"
	"net/http"
	"net/url"
	"strings"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
)

const lrcLibSearchURL = "https://lrclib.net/api/search"

type lrcLibSearchItem struct {
	ID           int    `json:"id"`
	Name         string `json:"name"`
	TrackName    string `json:"trackName"`
	ArtistName   string `json:"artistName"`
	AlbumName    string `json:"albumName"`
	Duration     int    `json:"duration"`
	Instrumental bool   `json:"instrumental"`
	PlainLyrics  string `json:"plainLyrics"`
	SyncedLyrics string `json:"syncedLyrics"`
}

func fetchLrclibLyrics(title, artist string) (*YouLyPlusLyricsResult, error) {
	searchQuery := title + " " + artist
	params := make(url.Values)
	params.Set("q", searchQuery)

	request, err := http.NewRequest(http.MethodGet, lrcLibSearchURL, nil)
	if err != nil {
		return nil, err
	}

	request.URL.RawQuery = params.Encode()
	request.Header.Set("User-Agent", "apple-music-web-components/"+amVersion)

	response, err := http.DefaultClient.Do(request)
	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	if response.StatusCode < 200 || response.StatusCode >= 300 {
		return nil, errors.New("Unsuccessful LRCLIB response.")
	}

	var searchResults []lrcLibSearchItem
	if err := json.NewDecoder(response.Body).Decode(&searchResults); err != nil {
		return nil, err
	}

	if len(searchResults) == 0 {
		return nil, errors.New("No LRCLIB lyrics found.")
	}

	// Prefer results with synced lyrics
	var syncedLyrics *lrcLibSearchItem
	for _, result := range searchResults {
		if result.SyncedLyrics != "" {
			syncedLyrics = &result
			break
		}
	}

	var bestMatch *lrcLibSearchItem
	if syncedLyrics != nil {
		bestMatch = syncedLyrics
	} else {
		bestMatch = &searchResults[0]
	}

	// Try synced lyrics first
	if bestMatch != nil {
		if bestMatch.SyncedLyrics != "" {
			lines, err := parseLrcSubtitles(bestMatch.SyncedLyrics)
			if err != nil {
				return nil, err
			}

			return &YouLyPlusLyricsResult{
				Lines:  lines,
				Source: "LRCLIB",
			}, nil
		}

		if bestMatch.PlainLyrics != "" {
			splitLines := strings.Split(bestMatch.PlainLyrics, "\n")
			lines := make([]*commonpb.LyricsLine, len(splitLines))

			for _, line := range splitLines {
				lines = append(lines, &commonpb.LyricsLine{
					Text: []*commonpb.LyricsLine_Syllable{{
						Text: strings.TrimSpace(line),
					}},
				})
			}

			return &YouLyPlusLyricsResult{
				Lines:  lines,
				Source: "LRCLIB (unsynced)",
			}, nil
		}
	}

	return nil, nil
}
