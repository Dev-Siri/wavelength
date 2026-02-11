package album_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/google/uuid"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (s *AlbumService) CreateTrackAlbum(
	ctx context.Context,
	request *albumpb.CreateTrackAlbumRequest,
) (*emptypb.Empty, error) {
	var existingAlbumsCount int

	row := shared_db.Database.QueryRow(`
		SELECT COUNT(*) FROM "albums"
		WHERE browse_id = $1 AND track_id = $2;
	`, request.BrowseId, request.TrackId)

	if err := row.Scan(&existingAlbumsCount); err != nil {
		logging.Logger.Error("Album count for authored track read failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Album count for authored track read failed.")
	}

	// Album is already recorded in the application DB.
	if existingAlbumsCount > 0 {
		return &emptypb.Empty{}, nil
	}

	albumId := uuid.NewString()

	_, err := shared_db.Database.Exec(`
		INSERT INTO "albums" (
			album_id,
			browse_id,
			track_id,
			title
		) VALUES ( $1, $2, $3, $4 );
	`, albumId, request.BrowseId, request.TrackId, request.Title)
	if err != nil {
		logging.Logger.Error("Track album creation failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Track album creation failed.")
	}

	return &emptypb.Empty{}, nil
}
