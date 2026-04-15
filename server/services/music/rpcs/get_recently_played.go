package music_rpcs

import (
	"context"
	"encoding/json"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/proto/yt_scraperpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	shared_constants "github.com/Dev-Siri/wavelength/server/shared/constants"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (m *MusicService) GetRecentlyPlayed(
	ctx context.Context,
	req *musicpb.GetRecentlyPlayedRequest,
) (*musicpb.GetRecentlyPlayedResponse, error) {
	cacheKey := shared_constants.HomeRecentlyPlayedKey.K(req.Email)
	cachedRecentlyPlayed, err := shared_db.Redis.JSONGet(ctx, cacheKey, "$").Result()
	if err != nil && err != redis.Nil {
		logging.Logger.Error("Cached recently played tracks fetch failed.", zap.Error(err))
	}

	var cachedTracks []*commonpb.Track

	if cachedRecentlyPlayed != "" && err != redis.Nil {
		if json.Unmarshal([]byte(cachedRecentlyPlayed), &cachedTracks); err != nil {
			logging.Logger.Error("Cached recently played tracks unmarshal failed.", zap.Error(err))
		}
	}

	rows, err := shared_db.AnalyticsDatabase.QueryContext(ctx, `
		SELECT video_id FROM (
			SELECT video_id, MAX(event_timestamp) AS latest_play
			FROM track_events
			WHERE email = $1 AND event_type = 'play_30s'
			GROUP BY video_id
		) t
		ORDER BY latest_play DESC
		LIMIT 6;
	`, req.Email)
	if err != nil {
		logging.Logger.Error("Recently played track IDs fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Recently played track IDs fetch failed.")
	}

	cachedTrackIDMap := make(map[string]*commonpb.Track)
	if len(cachedTracks) > 0 {
		for _, track := range cachedTracks {
			cachedTrackIDMap[track.VideoId] = track
		}
	}

	var recentTrackIDs []string

	for rows.Next() {
		var trackID string
		if err := rows.Scan(&trackID); err != nil {
			logging.Logger.Error("Recently played track IDs scan failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Recently played track IDs scan failed.")
		}

		recentTrackIDs = append(recentTrackIDs, trackID)
	}

	var recentlyPlayedTracks []*commonpb.Track
	for _, trackID := range recentTrackIDs {
		if track, exists := cachedTrackIDMap[trackID]; exists {
			recentlyPlayedTracks = append(recentlyPlayedTracks, track)
			continue
		}

		trackResponse, err := clients.YtScraperClient.GetTrackInfo(ctx, &yt_scraperpb.GetTrackInfoRequest{
			VideoId: trackID,
		})
		if err != nil {
			logging.Logger.Error("Track fetch failed.", zap.Error(err))
			continue
		}

		recentlyPlayedTracks = append(recentlyPlayedTracks, trackResponse.Track)
	}

	if _, err := shared_db.Redis.JSONSet(
		ctx,
		cacheKey,
		"$",
		recentlyPlayedTracks,
	).Result(); err != nil {
		logging.Logger.Error("Recently played tracks cache set failed.", zap.Error(err))
	}

	return &musicpb.GetRecentlyPlayedResponse{
		Tracks: recentlyPlayedTracks,
	}, nil
}
