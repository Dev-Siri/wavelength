package playlist_rpcs

import (
	"context"
	"database/sql"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	"github.com/Dev-Siri/wavelength/server/proto/yt_scraperpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/filtering"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (p *PlaylistService) GetSongRecommendations(
	ctx context.Context,
	request *playlistpb.GetSongRecommendationsRequest,
) (*playlistpb.GetSongRecommendationsResponse, error) {
	rows, err := shared_db.Database.Query(`
		SELECT
			video_id
		FROM "playlist_tracks"
		WHERE playlist_id = $1
		ORDER BY position_in_playlist DESC;
	`, request.PlaylistId)
	if err != nil {
		logging.Logger.Error("Playlist tracks fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Playlist tracks fetch failed.")
	}

	trackIDs := make([]string, 0)
	for rows.Next() {
		var trackID string
		if err := rows.Scan(&trackID); err != nil {
			if err == sql.ErrNoRows {
				logging.Logger.Error("Cannot provide song recommendations without at least one song in playlist.")
				return nil, status.Error(codes.NotFound, "Cannot provide song recommendations without at least one song in playlist.")
			}

			logging.Logger.Error("Parsing one video ID failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Parsing one video ID failed.")
		}

		trackIDs = append(trackIDs, trackID)
	}

	trackSet := filtering.NewSet(trackIDs...)
	lastVideoID := trackIDs[len(trackIDs)-1]
	musicRecommendationsResponse, err := clients.YtScraperClient.GetUpNext(ctx, &yt_scraperpb.GetUpNextRequest{
		VideoId: lastVideoID,
	})
	if err != nil {
		logging.Logger.Error("Recommendations fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Recommendations fetch failed.")
	}

	filteredTracks := make([]*commonpb.Track, 0, len(musicRecommendationsResponse.Tracks))
	for _, track := range musicRecommendationsResponse.Tracks {
		if trackSet.Contains(track.VideoId) {
			continue
		}

		filteredTracks = append(filteredTracks, track)
	}

	return &playlistpb.GetSongRecommendationsResponse{
		ContinuationToken: musicRecommendationsResponse.ContinuationToken,
		Tracks:            filteredTracks,
	}, nil
}
