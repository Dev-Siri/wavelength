package artist_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/artistpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (a *ArtistService) FollowArtist(
	ctx context.Context,
	request *artistpb.FollowArtistRequest,
) (*emptypb.Empty, error) {

	var followCount int

	row := shared_db.Database.QueryRow(`
		SELECT COUNT(*) FROM "follows"
		WHERE follower_email = $1 AND artist_browse_id = $2; 
	`, request.FollowerEmail, request.ArtistBrowseId)

	if err := row.Scan(&followCount); err != nil {
		logging.Logger.Error("Follow count read from database failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Follow count read from database failed.")
	}

	if followCount > 0 {
		_, err := shared_db.Database.Exec(`
			DELETE FROM "follows"
			WHERE follower_email = $1 AND artist_browse_id = $2;
		`, request.FollowerEmail, request.ArtistBrowseId)

		if err != nil {
			logging.Logger.Error("Artist unfollow failed.", zap.Error(err))
			return nil, status.Error(fiber.StatusInternalServerError, "Artist unfollow failed.")
		}

		return &emptypb.Empty{}, nil
	}

	_, err := shared_db.Database.Exec(`
			INSERT INTO "follows" (
				follower_email,
				follow_id,
				artist_name,
				artist_thumbnail,
				artist_browse_id
			) VALUES ( $1, $2, $3, $4, $5 );
		`, request.FollowerEmail, uuid.NewString(), request.ArtistName, request.ArtistThumbnail, request.ArtistBrowseId)

	if err != nil {
		logging.Logger.Error("Artist follow failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Artist follow failed.")
	}

	return &emptypb.Empty{}, nil
}
