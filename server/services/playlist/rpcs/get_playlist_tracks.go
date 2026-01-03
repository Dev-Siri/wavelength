package playlist_rpcs

import (
	"context"
	"html"
	"wavelength/proto/commonpb"
	"wavelength/proto/playlistpb"
	shared_db "wavelength/shared/db"
	"wavelength/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (p *PlaylistService) GetPlaylistTracks(
	ctx context.Context,
	request *playlistpb.GetPlaylistTracksRequest,
) (*playlistpb.GetPlaylistTracksResponse, error) {
	rows, err := shared_db.Database.Query(`
		SELECT
			playlist_track_id,
			title,
			thumbnail,
			position_in_playlist,
			is_explicit,
			author,
			duration,
			video_id,
			video_type,
			playlist_id
		FROM playlist_tracks
		WHERE playlist_id = $1
	`, request.PlaylistId)

	if err != nil {
		go logging.Logger.Error("Playlist tracks fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Playlist tracks fetch failed.")
	}

	playlistTracks := make([]*commonpb.PlaylistTrack, 0)

	for rows.Next() {
		var playlistTrack commonpb.PlaylistTrack
		var videoType string

		if err := rows.Scan(
			&playlistTrack.PlaylistTrackId,
			&playlistTrack.Title,
			&playlistTrack.Thumbnail,
			&playlistTrack.PositionInPlaylist,
			&playlistTrack.IsExplicit,
			&playlistTrack.Author,
			&playlistTrack.Duration,
			&playlistTrack.VideoId,
			&videoType,
			&playlistTrack.PlaylistId,
		); err != nil {
			go logging.Logger.Error("Parsing of one playlist track failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Parsing of one playlist track failed.")
		}

		if videoType == "uvideo" {
			playlistTrack.VideoType = commonpb.VideoType_VIDEO_TYPE_UVIDEO
		} else {
			playlistTrack.VideoType = commonpb.VideoType_VIDEO_TYPE_TRACK
		}

		playlistTrack.Title = html.UnescapeString(playlistTrack.Title)

		playlistTracks = append(playlistTracks, &playlistTrack)
	}

	return &playlistpb.GetPlaylistTracksResponse{
		PlaylistTracks: playlistTracks,
	}, nil
}
