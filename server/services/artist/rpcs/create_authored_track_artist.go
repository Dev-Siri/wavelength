package artist_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/artistpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/google/uuid"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (a *ArtistService) CreateAuthoredTrackArtist(
	ctx context.Context,
	request *artistpb.CreateAuthoredTrackArtistRequest,
) (*emptypb.Empty, error) {
	var existingArtistsCount int

	row := shared_db.Database.QueryRow(`
		SELECT COUNT(*) FROM "artists"
		WHERE browse_id = $1 AND authored_track_id = $2;
	`, request.BrowseId, request.AuthoredTrackId)

	if err := row.Scan(&existingArtistsCount); err != nil {
		logging.Logger.Error("Artist count for authored track read failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Artist count for authored track read failed.")
	}

	// Artist is already recorded in the application DB.
	if existingArtistsCount > 0 {
		return &emptypb.Empty{}, nil
	}

	artistId := uuid.NewString()

	_, err := shared_db.Database.Exec(`
		INSERT INTO "artists" (
			artist_id,
			browse_id,
			authored_track_id,
			title
		) VALUES ( $1, $2, $3, $4 );
	`, artistId, request.BrowseId, request.AuthoredTrackId, request.Title)
	if err != nil {
		logging.Logger.Error("Authored track artist creation failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Authored track artist creation failed.")
	}

	return &emptypb.Empty{}, nil
}
