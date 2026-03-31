package album_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/proto/yt_scraperpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/google/uuid"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *AlbumService) SaveAlbum(
	ctx context.Context,
	request *albumpb.SaveAlbumRequest,
) (*albumpb.SaveAlbumResponse, error) {
	row := shared_db.Database.QueryRow(`
		SELECT COUNT(*) FROM "saved_albums"
		WHERE album_id = $1 AND saver_email = $2;
	`, request.AlbumId, request.SaverEmail)

	var saveCount int
	if err := row.Scan(&saveCount); err != nil {
		logging.Logger.Error("Album save count fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Album save count fetch failed.")
	}

	isSaved := saveCount > 0
	if isSaved {
		_, err := shared_db.Database.Exec(`
			DELETE FROM "saved_albums"
			WHERE album_id = $1 AND saver_email = $2;
		`, request.AlbumId, request.SaverEmail)
		if err != nil {
			logging.Logger.Error("Album remove-save operation failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Album remove-save operation failed.")
		}

		return &albumpb.SaveAlbumResponse{
			SaveType: albumpb.SaveAlbumResponse_ALBUM_SAVE_TYPE_REMOVE_SAVE,
		}, nil
	}

	albumDetailsResponse, err := clients.YtScraperClient.GetAlbumDetails(ctx, &yt_scraperpb.GetAlbumDetailsRequest{
		AlbumId: request.AlbumId,
	})
	if err != nil {
		logging.Logger.Error("Album details fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Album details fetch failed.")
	}

	var storedAlbumType string
	switch albumDetailsResponse.Album.AlbumType {
	case commonpb.AlbumType_ALBUM_TYPE_EP:
		storedAlbumType = "ep"
	case commonpb.AlbumType_ALBUM_TYPE_SINGLE:
		storedAlbumType = "single"
	default:
		storedAlbumType = "album"
	}

	saveID := uuid.NewString()
	_, err = shared_db.Database.Exec(`
			INSERT INTO "saved_albums" (
				save_id,
				saver_email,
				album_id,
				title,
				album_cover,
				album_song_count,
				album_duration,
				album_author,
				album_type
			) VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9 );
		`, saveID, request.SaverEmail, request.AlbumId, albumDetailsResponse.Album.Title, albumDetailsResponse.Album.Cover,
		albumDetailsResponse.Album.TotalSongCount, albumDetailsResponse.Album.TotalDuration, albumDetailsResponse.Album.Artist.Title,
		storedAlbumType)
	if err != nil {
		logging.Logger.Error("Album add-save operation failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Album add-save operation failed.")
	}

	return &albumpb.SaveAlbumResponse{
		SaveType: albumpb.SaveAlbumResponse_ALBUM_SAVE_TYPE_ADD_SAVE,
	}, nil
}
