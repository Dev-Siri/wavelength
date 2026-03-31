package tidal

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"io"
	"math"
	"net/http"
	"slices"
	"strconv"
	"strings"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/proto/yt_scraperpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/Dev-Siri/wavelength/server/utils"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

type tidalHifiClient struct{}

const instanceURL = "https://singapore-1.monochrome.tf"

var Hifi = newTidalHifiClient()

func newTidalHifiClient() *tidalHifiClient {
	return &tidalHifiClient{}
}

type tidalResponse[T any] struct {
	Version string `json:"version"`
	Data    T      `json:"data"`
}

type tidalArtist struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type tidalSearchResponse struct {
	Items []struct {
		ID         int           `json:"id"`
		Title      string        `json:"title"`
		Duration   int           `json:"duration"`
		ISRC       string        `json:"isrc"`
		AudioModes []string      `json:"audioModes"`
		Explicit   bool          `json:"explicit"`
		Artists    []tidalArtist `json:"artists"`
		Album      struct {
			ID    int    `json:"id"`
			Title string `json:"title"`
		} `json:"album"`
	} `json:"items"`
}

type TrackResponse struct {
	AudioQuality     string `json:"audioQuality"`
	ManifestMimeType string `json:"manifestMimeType"`
	Manifest         string `json:"manifest"`
}

type universalIDCollection struct {
	TidalID        string
	DolbyAudioID   *string
	YoutubeMusicID string
	ISRC           string
}

func (*tidalHifiClient) GetLosslessManifest(tidalID string) (*tidalResponse[TrackResponse], error) {
	endpointURL := instanceURL + "/track"
	request, err := http.NewRequest(http.MethodGet, endpointURL, nil)
	if err != nil {
		return nil, err
	}

	queryParams := request.URL.Query()
	queryParams.Set("id", tidalID)

	request.URL.RawQuery = queryParams.Encode()

	response, err := http.DefaultClient.Do(request)
	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	var parsedTidalResponse tidalResponse[TrackResponse]

	bodyBytes, err := io.ReadAll(response.Body)
	if err != nil {
		return nil, err
	}

	logging.Logger.Debug("Tidal Hi-Fi Response.", zap.String("response", string(bodyBytes)))
	if err := json.Unmarshal(bodyBytes, &parsedTidalResponse); err != nil {
		return nil, err
	}

	return &parsedTidalResponse, nil
}

func (*tidalHifiClient) GetTrackUniversalIDs(track *commonpb.Track) (*universalIDCollection, error) {
	logging.Logger.Debug("Fetching Universal IDs with details.", zap.Any("track", track))
	endpointURL := instanceURL + "/search"
	request, err := http.NewRequest(http.MethodGet, endpointURL, nil)
	if err != nil {
		return nil, err
	}

	queryParams := request.URL.Query()

	queryParams.Set("i", track.Title+" "+utils.FormatAndJoinArtists(track.Artists))
	request.URL.RawQuery = queryParams.Encode()

	response, err := http.DefaultClient.Do(request)
	if err != nil {
		return nil, err
	}
	defer response.Body.Close()

	var parsedTidalResponse tidalResponse[tidalSearchResponse]
	if err := json.NewDecoder(response.Body).Decode(&parsedTidalResponse); err != nil {
		return nil, err
	}

	type candidate struct {
		stereoID *string
		dolbyID  *string
		isrc     string
		hasAlbum bool
	}

	// Group items by ISRC so stereo + dolby variants of the same
	// recording are merged into one candidate.
	candidatesByISRC := make(map[string]*candidate)

	for i, item := range parsedTidalResponse.Data.Items {
		explicitnessMatches := item.Explicit == (track.IsExplicit != nil && *track.IsExplicit)
		durationApproximatelyMatches := math.Abs(float64(int(track.Duration)-item.Duration)) <= 2

		titleMatches := strings.EqualFold(item.Title, track.Title)
		artistMatches := hasAtLeastOneArtistMatch(item.Artists, track.Artists)
		albumMatches := strings.EqualFold(item.Album.Title, track.Album.Title)

		logging.Logger.Debug("Evaluating item.",
			zap.Int("index", i), zap.Int("id", item.ID),
			zap.String("title", item.Title), zap.Any("audioModes", item.AudioModes),
			zap.Int("duration", item.Duration), zap.Bool("artistMatches", artistMatches),
			zap.Bool("albumMatches", albumMatches), zap.Bool("titleMatches", titleMatches),
			zap.Bool("explicitnessMatches", explicitnessMatches),
			zap.Bool("durationApproximatelyMatches", durationApproximatelyMatches),
		)

		if !artistMatches || (len(track.Artists) == 1 && !titleMatches) || !explicitnessMatches || !durationApproximatelyMatches {
			continue
		}

		isrc := item.ISRC
		c, exists := candidatesByISRC[isrc]
		if !exists {
			c = &candidate{isrc: isrc, hasAlbum: albumMatches}
			candidatesByISRC[isrc] = c
		}

		if albumMatches {
			c.hasAlbum = true
		}

		id := strconv.Itoa(item.ID)
		if slices.Contains(item.AudioModes, "STEREO") && c.stereoID == nil {
			c.stereoID = &id
		}
		if slices.Contains(item.AudioModes, "DOLBY_ATMOS") && c.dolbyID == nil {
			c.dolbyID = &id
		}
	}

	if len(candidatesByISRC) == 0 {
		return nil, errors.New("no valid universal ID found")
	}

	var best *candidate
	bestScore := -1

	for _, c := range candidatesByISRC {
		if c.stereoID == nil && c.dolbyID == nil {
			continue
		}
		score := 0
		if c.hasAlbum {
			score += 1
		}
		if c.stereoID != nil {
			score += 1
		}
		if score > bestScore {
			bestScore = score
			best = c
		}
	}

	if best == nil {
		return nil, errors.New("no valid universal ID found")
	}

	tidalID := best.stereoID
	if tidalID == nil {
		tidalID = best.dolbyID
	}

	result := &universalIDCollection{
		TidalID:        *tidalID,
		DolbyAudioID:   best.dolbyID,
		YoutubeMusicID: track.VideoId,
		ISRC:           best.isrc,
	}

	logging.Logger.Debug("Chosen candidate.",
		zap.String("tidalID", result.TidalID),
		zap.Any("dolbyAudioID", result.DolbyAudioID),
		zap.String("isrc", result.ISRC),
	)

	return result, nil
}

// Ensure Stream database and YT-Scraper initialization before call.
func (t *tidalHifiClient) FetchUniversalIDs(ctx context.Context, videoID string) (*universalIDCollection, error) {
	if shared_db.StreamDatabase == nil {
		return nil, errors.New("Stream database not initialized.")
	}
	if clients.YtScraperClient == nil {
		return nil, errors.New("YT Scraper not initialized.")
	}

	row := shared_db.StreamDatabase.QueryRow(`
		SELECT
			tidal_id,
			dolby_audio_id,
			youtube_music_id,
			isrc
		FROM "labels"
		WHERE youtube_music_id = $1;
	`, videoID)

	var storedUniversalIDs universalIDCollection
	var dolbyAudioID sql.NullString

	err := row.Scan(
		&storedUniversalIDs.TidalID,
		&dolbyAudioID,
		&storedUniversalIDs.YoutubeMusicID,
		&storedUniversalIDs.ISRC,
	)

	if err == nil {
		if dolbyAudioID.Valid {
			storedUniversalIDs.DolbyAudioID = &dolbyAudioID.String
		}
		return &storedUniversalIDs, nil
	}

	if err != sql.ErrNoRows {
		return nil, err
	}

	trackResponse, err := clients.YtScraperClient.GetTrackInfo(ctx, &yt_scraperpb.GetTrackInfoRequest{
		VideoId: videoID,
	})
	if err != nil {
		return nil, err
	}

	tidalResponse, err := t.GetTrackUniversalIDs(trackResponse.Track)
	if err != nil {
		return nil, err
	}

	labelID := uuid.NewString()
	_, err = shared_db.StreamDatabase.Exec(`
		INSERT INTO "labels" (
			label_id,
			isrc,
			title,
			artist,
			is_explicit,
			tidal_id,
			youtube_music_id,
			dolby_audio_id
		) VALUES ( $1, $2, $3, $4, $5, $6, $7, $8 )
	`, labelID, tidalResponse.ISRC, trackResponse.Track.Title, utils.FormatAndJoinArtists(trackResponse.Track.Artists),
		trackResponse.Track.IsExplicit != nil && *trackResponse.Track.IsExplicit, tidalResponse.TidalID, videoID, tidalResponse.DolbyAudioID)
	if err != nil {
		return nil, err
	}

	return tidalResponse, nil
}

func hasAtLeastOneArtistMatch(
	tidalArtists []tidalArtist,
	ytmArtists []*commonpb.EmbeddedArtist,
) bool {
	for _, tArtist := range tidalArtists {
		for _, yArtist := range ytmArtists {
			if strings.EqualFold(tArtist.Name, yArtist.Title) {
				return true
			}
		}
	}
	return false
}
