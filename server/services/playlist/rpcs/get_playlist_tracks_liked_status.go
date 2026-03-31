package playlist_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (p *PlaylistService) GetPlaylistTracksLikedStatus(
	ctx context.Context,
	request *playlistpb.GetPlaylistTracksLikedStatusRequest,
) (*playlistpb.GetPlaylistTracksLikedStatusResponse, error) {
	rows, err := shared_db.Database.Query(`
		SELECT 
			pt.video_id,
			(l.video_id IS NOT NULL) AS is_liked
		FROM playlist_tracks pt
		LEFT JOIN likes l
			ON pt.video_id = l.video_id
			AND l.email = $2
		WHERE pt.playlist_id = $1;
	`, request.PlaylistId, request.LikerEmail)
	if err != nil {
		logging.Logger.Error("Liked status fetch failed from database.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Liked status fetch failed from database.")
	}

	defer rows.Close()

	likedTracks := make(map[string]bool)
	for rows.Next() {
		var videoID string
		var isLiked bool

		if err := rows.Scan(&videoID, &isLiked); err != nil {
			logging.Logger.Error("Parsing one of the liked status failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Parsing one of the liked status failed.")
		}

		likedTracks[videoID] = isLiked
	}

	return &playlistpb.GetPlaylistTracksLikedStatusResponse{
		LikedTracks: likedTracks,
	}, nil
}
