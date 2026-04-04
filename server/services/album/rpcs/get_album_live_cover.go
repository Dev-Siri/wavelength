package album_rpcs

import (
	"context"
	"database/sql"
	"io"
	"net/http"
	"net/url"
	"regexp"

	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/Dev-Siri/wavelength/server/shared/spotify"
	"github.com/Dev-Siri/wavelength/server/shared/tidal"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

var m3u8Regex = regexp.MustCompile(`https://[^"]+\.m3u8`)
var ampAmbientVideoRegex = regexp.MustCompile(`<amp-ambient-video[^>]+src="([^"]+\.m3u8[^"]*)"`)

func (a *AlbumService) GetAlbumLiveCover(
	ctx context.Context,
	request *albumpb.GetAlbumLiveCoverRequest,
) (*albumpb.GetAlbumLiveCoverResponse, error) {
	appleMusicURL, err := fetchStoredAppleMusicURL(ctx, request.AlbumId)
	if err != nil {
		logging.Logger.Error("Stored Apple Music URL fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Stored Apple Music URL fetch failed.")
	}

	logging.Logger.Debug("appleMusicURL from database.", zap.Any("appleMusicURL", appleMusicURL))
	if appleMusicURL == "" {
		universalIDs, err := tidal.Hifi.FetchUniversalIDs(ctx, request.VideoId)
		if err != nil {
			logging.Logger.Error("Universal ID fetch failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Universal ID fetch failed.")
		}

		appleMusicURL, err = spotify.MusicFetch.FetchAppleMusicURL(ctx, request.AlbumId, universalIDs.ISRC)
		if err != nil {
			logging.Logger.Error("Apple Music URL fetch failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Apple Music URL fetch failed.")
		}
	}

	logging.Logger.Debug("Requesting appleMusicURL.", zap.String("appleMusicURL", appleMusicURL))
	parsedURL, err := url.Parse(appleMusicURL)
	if err != nil {
		logging.Logger.Error("Query params removal failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Query params removal failed.")
	}

	parsedURL.RawQuery = ""
	response, err := http.Get(parsedURL.String())
	if err != nil {
		logging.Logger.Error("Apple Music webpage request failed..", zap.Error(err))
		return nil, status.Error(codes.Internal, "Apple Music webpage request failed..")
	}

	defer response.Body.Close()

	body, err := io.ReadAll(response.Body)
	if err != nil {
		logging.Logger.Error("Apple Music webpage read failed.", zap.Error(err))
	}

	liveCoverURI := m3u8Regex.FindString(string(body))

	// Try to extract from <amp-ambient-video src="...">
	if liveCoverURI == "" {
		matches := ampAmbientVideoRegex.FindStringSubmatch(string(body))
		if len(matches) > 1 {
			liveCoverURI = matches[1]
		}
	}

	var liveAlbumCoverURI *string
	if liveCoverURI != "" {
		liveAlbumCoverURI = &liveCoverURI
	}

	logging.Logger.Debug("After search for liveCoverURI.", zap.Any("liveCoverURI", liveCoverURI))

	return &albumpb.GetAlbumLiveCoverResponse{
		LiveAlbumCoverUri: liveAlbumCoverURI,
	}, nil
}

func fetchStoredAppleMusicURL(ctx context.Context, albumID string) (string, error) {
	row := shared_db.StreamDatabase.QueryRowContext(ctx, `
		SELECT apple_music_url FROM "apple_music_urls"
		WHERE album_id = $1;
	`, albumID)

	var storedAppleMusicURL string
	if err := row.Scan(&storedAppleMusicURL); err != nil {
		if err == sql.ErrNoRows {
			return "", nil
		}
		return "", err
	}

	return storedAppleMusicURL, nil
}
