package artist_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/artistpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *ArtistService) IsFollowingArtist(
	ctx context.Context,
	request *artistpb.IsFollowingArtistRequest,
) (*artistpb.IsFollowingArtistResponse, error) {
	var followingCount int

	row := shared_db.Database.QueryRow(`
		SELECT COUNT(*) FROM "follows"
		WHERE artist_browse_id = $1 AND follower_email = $2;
	`, request.BrowseId, request.FollowerEmail)

	if err := row.Scan(&followingCount); err != nil {
		logging.Logger.Error("Following count read from database failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Following count read from database failed.")
	}

	isFollowingArtist := followingCount > 0
	return &artistpb.IsFollowingArtistResponse{
		IsFollowing: &isFollowingArtist,
	}, nil
}
