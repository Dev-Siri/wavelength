package music_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (m *MusicService) IsTrackLiked(
	ctx context.Context,
	request *musicpb.IsTrackLikedRequest,
) (*musicpb.IsTrackLikedResponse, error) {
	var likesCount int

	row := shared_db.Database.QueryRow(`
		SELECT COUNT(*) FROM "likes"
		WHERE email = $1 AND video_id = $2;
	`, request.LikerEmail, request.VideoId)

	if err := row.Scan(&likesCount); err != nil {
		logging.Logger.Error("Like count read failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Like count read failed.")
	}

	isLiked := likesCount > 0
	return &musicpb.IsTrackLikedResponse{
		IsLiked: &isLiked,
	}, nil
}
