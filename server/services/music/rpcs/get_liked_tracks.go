package music_rpcs

import (
	"context"
	"html"
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
			l.like_id,
			l.email,
			l.title,
			l.thumbnail,
			l.is_explicit,
			l.duration,
			l.video_id,
			l.video_type,

			a.title AS artist_title,
			a.browse_id AS artist_browse_id
		FROM "likes" l
		LEFT JOIN "artists" a
		ON l.video_id = a.authored_track_id
		WHERE l.email = $1
		ORDER BY l.created_at;
	`, request.LikerEmail)

	if err != nil {
		go logging.Logger.Error("Liked tracks fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Liked tracks fetch failed.")
	}

	defer rows.Close()

	tracks := make(map[string]*commonpb.LikedTrack)

	for rows.Next() {
		var (
			likeId     string
			email      string
			title      string
			thumbnail  string
			isExplicit bool
			duration   uint64
			videoId    string
			videoType  string

			artistTitle    string
			artistBrowseId string
		)

		if err := rows.Scan(
			&likeId,
			&email,
			&title,
			&thumbnail,
			&isExplicit,
			&duration,
			&videoId,
			&videoType,
			&artistTitle,
			&artistBrowseId,
		); err != nil {
			go logging.Logger.Error("Parsing of one liked track failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Parsing of one liked track failed.")
		}

		track, exists := tracks[likeId]
		if !exists {
			track = &commonpb.LikedTrack{
				LikeId:     likeId,
				Title:      html.UnescapeString(title),
				Thumbnail:  thumbnail,
				IsExplicit: &isExplicit,
				Duration:   duration,
				VideoId:    videoId,
				Email:      email,
				Artists:    []*commonpb.EmbeddedArtist{},
			}

			if videoType == "uvideo" {
				track.VideoType = commonpb.VideoType_VIDEO_TYPE_UVIDEO
			} else {
				track.VideoType = commonpb.VideoType_VIDEO_TYPE_TRACK
			}

			tracks[likeId] = track
		}

		track.Artists = append(track.Artists, &commonpb.EmbeddedArtist{
			Title:    artistTitle,
			BrowseId: artistBrowseId,
		})
	}

	likedTracks := make([]*commonpb.LikedTrack, 0, len(tracks))
	for _, t := range tracks {
		likedTracks = append(likedTracks, t)
	}

	return &musicpb.GetLikedTracksResponse{
		LikedTracks: likedTracks,
	}, nil
}
