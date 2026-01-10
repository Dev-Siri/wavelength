package music_rpcs

import (
	"context"
	"wavelength/proto/artistpb"
	"wavelength/proto/commonpb"
	"wavelength/proto/musicpb"
	shared_clients "wavelength/shared/clients"
	shared_db "wavelength/shared/db"
	"wavelength/shared/logging"

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
		go logging.Logger.Error("Like data count read failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Like data count read failed.")
	}

	if likesCount > 0 {
		// Perform unlike instead.
		_, err := shared_db.Database.Exec(`
			DELETE FROM "likes"
			WHERE email = $1 AND video_id = $2;
		`, request.LikerEmail, request.VideoId)

		if err != nil {
			go logging.Logger.Error("Track unlike failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Track unlike failed.")
		}

		return &musicpb.LikeTrackResponse{
			LikeType: musicpb.LikeTrackResponse_LIKE_TYPE_UNLIKE,
		}, nil
	}

	for _, artist := range request.Artists {
		_, err := shared_clients.ArtistClient.CreateAuthoredTrackArtist(ctx, &artistpb.CreateAuthoredTrackArtistRequest{
			AuthoredTrackId: request.VideoId,
			BrowseId:        artist.BrowseId,
			Title:           artist.Title,
		})

		if err != nil {
			go logging.Logger.Error("Storing artists failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Storing artists failed.")
		}
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
		go logging.Logger.Error("Like track failed.", zap.Error(err))
		return nil, status.Error(fiber.StatusInternalServerError, "Like track failed.")
	}

	return &musicpb.LikeTrackResponse{
		LikeType: musicpb.LikeTrackResponse_LIKE_TYPE_LIKE,
	}, nil
}
