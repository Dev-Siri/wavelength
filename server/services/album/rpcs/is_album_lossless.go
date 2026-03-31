package album_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	"github.com/Dev-Siri/wavelength/server/proto/yt_scraperpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/lib/pq"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *AlbumService) IsAlbumLossless(
	ctx context.Context,
	request *albumpb.IsAlbumLosslessRequest,
) (*albumpb.IsAlbumLosslessResponse, error) {
	albumResponse, err := clients.YtScraperClient.GetAlbumDetails(ctx, &yt_scraperpb.GetAlbumDetailsRequest{
		AlbumId: request.AlbumId,
	})
	if err != nil {
		logging.Logger.Error("Album tracks fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Album tracks fetch failed.")
	}

	albumTrackIDs := make([]string, 0, len(albumResponse.Album.AlbumTracks))
	for _, albumTrack := range albumResponse.Album.AlbumTracks {
		albumTrackIDs = append(albumTrackIDs, albumTrack.VideoId)
	}

	row := shared_db.StreamDatabase.QueryRow(`
		SELECT COUNT(*)
		FILTER (WHERE is_lossless_available IS NOT NULL) = $2
		FROM "stream_metadata"
		WHERE video_id = ANY($1);
	`, pq.Array(albumTrackIDs), len(albumTrackIDs))

	var isLossless bool
	if err := row.Scan(&isLossless); err != nil {
		logging.Logger.Error("Album availability count fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Album availability count fetch failed.")
	}

	return &albumpb.IsAlbumLosslessResponse{
		IsLossless: &isLossless,
	}, nil
}
