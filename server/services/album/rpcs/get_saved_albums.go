package album_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *AlbumService) GetSavedAlbums(
	ctx context.Context,
	request *albumpb.GetSavedAlbumsRequest,
) (*albumpb.GetSavedAlbumsResponse, error) {
	rows, err := shared_db.Database.Query(`
		SELECT
			saver_email,
			album_id,
			title,
			album_cover,
			album_song_count,
			album_duration,
			album_author,
			album_type
		FROM "saved_albums"
		WHERE saver_email = $1
	`, request.SaverEmail)
	if err != nil {
		logging.Logger.Error("Saved albums fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Saved albums fetch failed.")
	}

	savedAlbums := make([]*commonpb.SavedAlbum, 0)
	for rows.Next() {
		var savedAlbum commonpb.SavedAlbum
		var storedAlbumType string

		if err := rows.Scan(
			&savedAlbum.SaverEmail,
			&savedAlbum.AlbumId,
			&savedAlbum.Title,
			&savedAlbum.AlbumCover,
			&savedAlbum.AlbumSongCount,
			&savedAlbum.AlbumDuration,
			&savedAlbum.AlbumAuthor,
			&storedAlbumType,
		); err != nil {
			logging.Logger.Error("Parsing one of the saved albums failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Parsing one of the saved albums failed.")
		}

		switch storedAlbumType {
		case "ep":
			savedAlbum.AlbumType = commonpb.AlbumType_ALBUM_TYPE_EP
		case "single":
			savedAlbum.AlbumType = commonpb.AlbumType_ALBUM_TYPE_SINGLE
		default:
			savedAlbum.AlbumType = commonpb.AlbumType_ALBUM_TYPE_ALBUM
		}

		savedAlbums = append(savedAlbums, &savedAlbum)
	}

	return &albumpb.GetSavedAlbumsResponse{
		Albums: savedAlbums,
	}, nil
}
