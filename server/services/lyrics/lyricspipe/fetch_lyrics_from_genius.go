package lyricspipe

import (
	"encoding/json"
	"net/http"
	"net/url"
	"strings"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
)

type geniusLyricsResponse struct {
	Lyrics string `json:"lyrics"`
	URL    string `json:"url"`
	Title  string `json:"title"`
	Artist string `json:"artist"`
	Score  int    `json:"score"`
	Source string `json:"source"`
}

func fetchLyricsFromGenius(title, artist string) (*YouLyPlusLyricsResult, error) {
	params := make(url.Values)
	params.Set("title", title)
	params.Set("artist", artist)

	request, err := http.NewRequest(http.MethodGet, geniusWorkerURL, nil)
	if err != nil {
		return nil, err
	}

	request.URL.RawQuery = params.Encode()
	response, err := http.DefaultClient.Do(request)
	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		return nil, err
	}

	var geniusResponse geniusLyricsResponse
	if err = json.NewDecoder(response.Body).Decode(&geniusResponse); err != nil {
		return nil, err
	}

	if geniusResponse.Lyrics == "" {
		return nil, nil
	}

	plainLines := make([]*commonpb.LyricsLine, 0)
	for _, splitLine := range strings.Split(geniusResponse.Lyrics, "\n") {
		line := strings.TrimSpace(splitLine)
		if strings.HasPrefix(line, "[") {
			continue
		}

		plainLines = append(plainLines, &commonpb.LyricsLine{
			Text: []*commonpb.LyricsLine_Syllable{{
				Text: line,
			}},
		})
	}

	if len(plainLines) > 0 {
		return &YouLyPlusLyricsResult{
			Lines:  plainLines,
			Source: "Genius",
		}, nil
	}

	return nil, nil
}
