package lyricspipe

import "strings"

func FetchLyrics(
	title, artist, album string,
	durationMs float64, isrc *string,
) ([]YouLyPlusLyricsResult, error) {
	collectedSources := make([]YouLyPlusLyricsResult, 0)
	nTitle := strings.TrimSpace(title)
	nArtist := strings.TrimSpace(artist)
	nAlbum := strings.TrimSpace(album)

	results, err := fetchLyricsFromYouLyPlus(
		nTitle,
		nArtist,
		nAlbum,
		durationMs,
	)
	if err == nil && len(results) > 0 {
		collectedSources = append(collectedSources, results...)
	}

	if len(collectedSources) == 0 {
		result, err := fetchLyricsFromTidal(
			nTitle,
			nArtist,
			isrc,
		)
		if err == nil && result != nil {
			collectedSources = append(collectedSources, *result)
		}
	}

	if len(collectedSources) == 0 {
		result, err := fetchLrclibLyrics(
			nTitle,
			nArtist,
		)
		if err == nil && result != nil {
			collectedSources = append(collectedSources, *result)
		}
	}

	if len(collectedSources) == 0 {
		result, err := fetchLyricsFromGenius(
			nTitle,
			nArtist,
		)
		if err == nil && result != nil {
			collectedSources = append(collectedSources, *result)
		}
	}

	if len(collectedSources) > 0 {
		return mergeAndSortSources(collectedSources), nil
	}

	return []YouLyPlusLyricsResult{}, nil
}
