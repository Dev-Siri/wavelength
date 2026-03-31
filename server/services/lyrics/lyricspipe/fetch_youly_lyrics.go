package lyricspipe

import (
	"encoding/json"
	"io"
	"math"
	"math/rand"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

type providerResponsePart struct {
	Metadata *struct {
		Source   string `json:"source"`
		Provider string `json:"provider"`
	} `json:"metadata"`
}

func fetchLyricsFromYouLyPlus(
	title, artist, album string,
	durationMs float64,
) ([]YouLyPlusLyricsResult, error) {
	queryParams := make(url.Values)

	queryParams.Set("title", title)
	queryParams.Set("artist", artist)
	queryParams.Set("album", album)

	if durationMs > 0 {
		queryParams.Set("duration", string(strconv.FormatFloat(math.Round(durationMs/1000), 'f', 0, 64)))
	}

	queryParams.Set("source", defaultKpoeSourceOrder)

	allResults := make([]YouLyPlusLyricsResult, 0)

	cacheRequest, err := http.NewRequest(http.MethodGet, cacheServerURL, nil)
	if err != nil {
		return nil, err
	}

	cacheQueryParams := cacheRequest.URL.Query()

	cacheQueryParams.Set("track", title)
	cacheQueryParams.Set("artist", artist)
	cacheQueryParams.Set("album", album)

	if durationMs > 0 {
		cacheQueryParams.Set("duration", strconv.FormatFloat(math.Round((durationMs)/1000), 'f', 0, 64))
	}

	cacheRequest.URL.RawQuery = cacheQueryParams.Encode()

	cacheResponse, err := http.DefaultClient.Do(cacheRequest)

	if err == nil && cacheResponse != nil && cacheResponse.StatusCode >= 200 && cacheResponse.StatusCode < 300 {
		defer cacheResponse.Body.Close()
		type biniResult struct {
			Results []struct {
				ID         string `json:"id"`
				TrackName  string `json:"track_name"`
				ArtistName string `json:"artist_name"`
				AlbumName  string `json:"album_name"`
				Duration   int    `json:"duration"`
				ISRC       string `json:"isrc"`
				TimingType string `json:"timing_type"`
				LyricsURL  string `json:"lyricsUrl"`
			} `json:"results"`
		}

		var cacheData biniResult

		if err := json.NewDecoder(cacheResponse.Body).Decode(&cacheData); err != nil {
			return nil, err
		}

		if len(cacheData.Results) > 0 {
			result := cacheData.Results[0]
			if result.TimingType == "word" && result.LyricsURL != "" {
				ttmlResponse, err := http.DefaultClient.Get(result.LyricsURL)

				if err == nil && ttmlResponse != nil && ttmlResponse.StatusCode >= 200 && ttmlResponse.StatusCode < 300 {
					defer ttmlResponse.Body.Close()
					ttmlTextBytes, err := io.ReadAll(ttmlResponse.Body)
					if err != nil {
						return nil, err
					}

					lines, err := parseTTML(string(ttmlTextBytes))
					if err != nil {
						return nil, err
					}

					if len(lines) > 0 {
						allResults = append(allResults, YouLyPlusLyricsResult{
							Lines:  lines,
							Source: "BiniLyrics",
						})
						return allResults, nil
					}
				}
			} else {
				// Not word type, try QQ
				qqRequest, err := http.NewRequest(http.MethodGet, directKpoeServerURL, nil)
				if err != nil {
					return nil, err
				}

				qqParams := make(url.Values)
				for k, v := range queryParams {
					copied := make([]string, len(v))
					copy(copied, v)
					qqParams[k] = copied
				}

				qqParams.Set("source", "qq")
				qqRequest.URL.RawQuery = qqParams.Encode()

				qqResponse, err := http.DefaultClient.Do(qqRequest)
				if err == nil && qqResponse != nil && qqResponse.StatusCode >= 200 && qqResponse.StatusCode < 300 {
					defer qqResponse.Body.Close()
					payloadBytes, err := io.ReadAll(qqResponse.Body)
					if err != nil {
						return nil, err
					}

					lines, err := parseKPoeLyrics(payloadBytes)
					if err != nil {
						return nil, err
					}

					hasWordSync := false
					for _, line := range lines {
						if len(line.Text) > 1 {
							hasWordSync = true
							break
						}
					}

					if len(lines) > 0 && hasWordSync {
						allResults = append(allResults, YouLyPlusLyricsResult{
							Source: "QQ",
							Lines:  lines,
						})
						return allResults, nil
					}
				}

				if result.LyricsURL != "" {
					// If QQ fails or has no word sync, fall back to bini lyrics
					ttmlResponse, err := http.DefaultClient.Get(result.LyricsURL)
					if err == nil && ttmlResponse.Body != nil && ttmlResponse.StatusCode >= 200 && ttmlResponse.StatusCode < 300 {
						defer ttmlResponse.Body.Close()
						ttmlTextBytes, err := io.ReadAll(ttmlResponse.Body)
						if err != nil {
							return nil, err
						}

						lines, err := parseTTML(string(ttmlTextBytes))
						if err != nil {
							return nil, err
						}

						if len(lines) > 0 {
							allResults = append(allResults, YouLyPlusLyricsResult{
								Lines:  lines,
								Source: "BiniLyrics",
							})
							return allResults, nil
						}
					}
				}
			}
		}
	}

	// Shuffle servers so we pick a random one first, with all others as fallback
	// Limit to 2 servers to prevent unnecessary API spam when Apple lyrics are missing
	shuffledServers := shuffleAndPick(kpoeServers, 2)

	for _, base := range shuffledServers {
		// Trim any trailing slashes at URL end.
		normalizedBase := strings.TrimSuffix(base, "/")
		request, err := http.NewRequest(http.MethodGet, normalizedBase+"/v2/lyrics/get", nil)
		if err != nil {
			return nil, err
		}

		request.URL.RawQuery = queryParams.Encode()

		response, err := http.DefaultClient.Do(request)
		if err != nil {
			continue
		}

		payloadBytes, err := io.ReadAll(response.Body)
		if err != nil {
			response.Body.Close()
			continue
		}

		lines, err := parseKPoeLyrics(payloadBytes)
		if err != nil {
			response.Body.Close()
			continue
		}

		if len(lines) > 0 {
			var providerPart providerResponsePart
			if err := json.Unmarshal(payloadBytes, &providerPart); err != nil {
				response.Body.Close()
				continue
			}

			var sourceLabel = "LyricsPlus (KPoe)"
			if providerPart.Metadata != nil {
				if providerPart.Metadata.Source != "" {
					sourceLabel = providerPart.Metadata.Source
				} else if providerPart.Metadata.Provider != "" {
					sourceLabel = providerPart.Metadata.Provider
				}
			}

			// grpcLines := make([]*commonpb.LyricsLine, 0, len(lines))
			// for _, line := range lines {
			// 	grpcLines = append(grpcLines, &commonpb.LyricsLine{
			// 		Text: line.Text,
			// 		Background: line.Background,
			// 		BackgroundText: line.BackgroundText,
			// 		OppositeTurn: line.OppositeTurn,
			// 		Timestamp: line.Timestamp,
			// 		Endtime: line.Endtime,
			// 		IsWordSynced: line.IsWordSynced,
			// 		Alignment: line.Alignment,
			// 		SongPart: line.SongPart,
			// 		RomanizedText: line.RomanizedText,
			// 		Translation: line.Translation,
			// 	})
			// }

			rank := getRank(sourceLabel, lines)
			allResults = append(allResults, YouLyPlusLyricsResult{
				Source: sourceLabel,
				Lines:  lines,
			})

			response.Body.Close()
			// If source is Apple synced, we have the best so we can just immediately break the sweep
			if rank == 1 {
				break
			}
		}
	}

	// If we haven't found a completely synced Apple/QQ result (rank 1 or 2) among the servers,
	// force an explicit query against lyricsplus.binimum.org looking for QQ
	hasHighRankResult := false
	for _, result := range allResults {
		if getRank(result.Source, result.Lines) <= 2 {
			hasHighRankResult = true
			break
		}
	}

	if !hasHighRankResult {
		qqRequest, err := http.NewRequest(http.MethodGet, directKpoeServerURL, nil)
		if err != nil {
			return nil, err
		}

		qqParams := make(url.Values)
		for k, v := range queryParams {
			copied := make([]string, len(v))
			copy(copied, v)
			qqParams[k] = copied
		}

		qqParams.Set("source", "qq")
		qqRequest.URL.RawQuery = qqParams.Encode()

		response, err := http.DefaultClient.Do(qqRequest)
		if err != nil {
			return nil, err
		}

		defer response.Body.Close()

		payloadBytes, err := io.ReadAll(response.Body)
		if err != nil {
			return nil, err
		}

		lines, err := parseKPoeLyrics(payloadBytes)
		if err != nil {
			return nil, err
		}

		var providerPart providerResponsePart
		if err := json.Unmarshal(payloadBytes, &providerPart); err != nil {
			return nil, err
		}

		var sourceLabel = "LyricsPlus (KPoe)"
		if providerPart.Metadata != nil {
			if providerPart.Metadata.Source != "" {
				sourceLabel = providerPart.Metadata.Source
			} else if providerPart.Metadata.Provider != "" {
				sourceLabel = providerPart.Metadata.Provider
			}
		}

		if len(lines) > 0 {
			allResults = append(allResults, YouLyPlusLyricsResult{
				Source: sourceLabel,
				Lines:  lines,
			})
		}
	}

	return allResults, nil
}

func shuffleAndPick(servers []string, n int) []string {
	shuffled := make([]string, len(servers))
	copy(shuffled, servers)

	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	r.Shuffle(len(shuffled), func(i, j int) {
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	})

	if n > len(shuffled) {
		n = len(shuffled)
	}
	return shuffled[:n]
}
