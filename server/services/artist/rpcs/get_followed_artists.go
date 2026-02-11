package artist_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/artistpb"
	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *ArtistService) GetFollowedArtists(
	ctx context.Context,
	request *artistpb.GetFollowedArtistsRequest,
) (*artistpb.GetFollowedArtistsResponse, error) {
	rows, err := shared_db.Database.Query(`
		SELECT
			follow_id,
			follower_email,
			artist_name,
			artist_thumbnail,
			artist_browse_id
		FROM "follows"
		WHERE follower_email = $1
		ORDER BY followed_at;
	`, request.FollowerEmail)

	if err != nil {
		logging.Logger.Error("Followed artists fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Followed artists fetch failed.")
	}

	followedArtists := make([]*commonpb.FollowedArtist, 0)

	for rows.Next() {
		var followedArtist commonpb.FollowedArtist

		if err := rows.Scan(
			&followedArtist.FollowId,
			&followedArtist.FollowerEmail,
			&followedArtist.Name,
			&followedArtist.Thumbnail,
			&followedArtist.BrowseId,
		); err != nil {
			logging.Logger.Error("Parsing of one followed artist failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Parsing of one followed artist failed.")
		}

		followedArtists = append(followedArtists, &followedArtist)
	}

	return &artistpb.GetFollowedArtistsResponse{
		Artists: followedArtists,
	}, nil
}
