package album_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *AlbumService) IsAlbumSaved(
	ctx context.Context,
	request *albumpb.IsAlbumSavedRequest,
) (*albumpb.IsAlbumSavedResponse, error) {
	row := shared_db.Database.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM "saved_albums"
		WHERE album_id = $1 AND saver_email = $2;
	`, request.AlbumId, request.SaverEmail)

	var saveCount int
	if err := row.Scan(&saveCount); err != nil {
		logging.Logger.Error("Album save count fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Album save count fetch failed.")
	}

	isSaved := saveCount > 0
	return &albumpb.IsAlbumSavedResponse{
		IsSaved: &isSaved,
	}, nil
}
