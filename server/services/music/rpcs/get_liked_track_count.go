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

func (m *MusicService) GetLikedTrackCount(
	ctx context.Context,
	request *musicpb.GetLikedTrackCountRequest,
) (*musicpb.GetLikedTrackCountResponse, error) {
	var likeCount int

	row := shared_db.Database.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM "likes"
		WHERE email = $1;
	`, request.LikerEmail)

	if err := row.Scan(&likeCount); err != nil {
		logging.Logger.Error("Like count read failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Like count read failed.")
	}

	likeCountValue := uint32(likeCount)
	return &musicpb.GetLikedTrackCountResponse{
		LikeCount: &likeCountValue,
	}, nil
}
