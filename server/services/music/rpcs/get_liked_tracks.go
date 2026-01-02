package music_rpcs

import (
	"context"
	"wavelength/proto/commonpb"
	"wavelength/proto/musicpb"
	shared_db "wavelength/shared/db"
	"wavelength/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (m *MusicService) GetLikedTracks(
	ctx context.Context,
	request *musicpb.GetLikedTracksRequest,
) (*musicpb.GetLikedTracksResponse, error) {
	rows, err := shared_db.Database.Query(`
		SELECT
			like_id,
			email,
			title,
			thumbnail,
			is_explicit,
			author,
			duration,
			video_id,
			video_type
		FROM "likes"
		WHERE email = $1;
	`, request.LikerEmail)

	if err != nil {
		go logging.Logger.Error("Liked tracks fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Liked tracks fetch failed.")
	}

	defer rows.Close()

	likedTracks := make([]*commonpb.LikedTrack, 0)

	for rows.Next() {
		var likedTrack commonpb.LikedTrack

		if err := rows.Scan(
			&likedTrack.LikeId,
			&likedTrack.Email,
			&likedTrack.Title,
			&likedTrack.Thumbnail,
			&likedTrack.IsExplicit,
			&likedTrack.Author,
			&likedTrack.Duration,
			&likedTrack.VideoId,
			&likedTrack.VideoType,
		); err != nil {
			go logging.Logger.Error("Parsing of one liked track failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Parsing of one liked track failed.")
		}

		likedTracks = append(likedTracks, &likedTrack)
	}

	return &musicpb.GetLikedTracksResponse{
		LikedTracks: likedTracks,
	}, nil
}
