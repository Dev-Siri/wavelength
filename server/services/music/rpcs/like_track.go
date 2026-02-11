package music_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_musicmeta "github.com/Dev-Siri/wavelength/server/shared/musicmeta"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (m *MusicService) LikeTrack(
	ctx context.Context,
	request *musicpb.LikeTrackRequest,
) (*musicpb.LikeTrackResponse, error) {
	// Check if already liked.
	var likesCount int

	row := shared_db.Database.QueryRow(`
		SELECT COUNT(*) FROM "likes"
		WHERE email = $1 AND video_id = $2;
	`, request.LikerEmail, request.VideoId)

	if err := row.Scan(&likesCount); err != nil {
		logging.Logger.Error("Like data count read failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Like data count read failed.")
	}

	if likesCount > 0 {
		// Perform unlike instead.
		_, err := shared_db.Database.Exec(`
			DELETE FROM "likes"
			WHERE email = $1 AND video_id = $2;
		`, request.LikerEmail, request.VideoId)

		if err != nil {
			logging.Logger.Error("Track unlike failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Track unlike failed.")
		}

		return &musicpb.LikeTrackResponse{
			LikeType: musicpb.LikeTrackResponse_LIKE_TYPE_UNLIKE,
		}, nil
	}

	if err := shared_musicmeta.PrestoreArtists(request.VideoId, request.Artists); err != nil {
		logging.Logger.Error("Artist prestorage failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Artist prestorage failed.")
	}

	if err := shared_musicmeta.PrestoreAlbum(request.VideoId, request.Album); err != nil {
		logging.Logger.Error("Album prestorage failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Album prestorage failed.")
	}

	// Perform a like.
	likeId := uuid.NewString()

	dbVideoType := "track"
	if request.VideoType == commonpb.VideoType_VIDEO_TYPE_UVIDEO {
		dbVideoType = "uvideo"
	}

	_, err := shared_db.Database.Exec(`
		INSERT INTO "likes" (
			like_id,
			email,
			title,
			thumbnail,
			is_explicit,
			duration,
			video_id,
			video_type
		) VALUES ( $1, $2, $3, $4, $5, $6, $7, $8 );
	`, likeId, request.LikerEmail, request.Title, request.Thumbnail, request.IsExplicit,
		request.Duration, request.VideoId, dbVideoType)

	if err != nil {
		logging.Logger.Error("Like track failed.", zap.Error(err))
		return nil, status.Error(fiber.StatusInternalServerError, "Like track failed.")
	}

	return &musicpb.LikeTrackResponse{
		LikeType: musicpb.LikeTrackResponse_LIKE_TYPE_LIKE,
	}, nil
}
