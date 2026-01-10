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
			pt.playlist_track_id,
			pt.title,
			pt.thumbnail,
			pt.position_in_playlist,
			pt.is_explicit,
			pt.duration,
			pt.video_id,
			pt.video_type,
			pt.playlist_id,

			a.title AS artist_title,
			a.browse_id AS artist_browse_id
		FROM "playlist_tracks" pt
		LEFT JOIN "artists" a
		ON pt.video_id = a.authored_track_id
		WHERE pt.playlist_id = $1
	`, request.PlaylistId)

	if err != nil {
		go logging.Logger.Error("Playlist tracks fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Playlist tracks fetch failed.")
	}

	defer rows.Close()

	tracks := make(map[string]*commonpb.PlaylistTrack)

	for rows.Next() {
		var (
			playlistTrackId string
			title           string
			thumbnail       string
			position        uint32
			isExplicit      bool
			duration        uint64
			videoId         string
			videoType       string
			playlistId      string

			artistTitle    string
			artistBrowseId string
		)

		if err := rows.Scan(
			&playlistTrackId,
			&title,
			&thumbnail,
			&position,
			&isExplicit,
			&duration,
			&videoId,
			&videoType,
			&playlistId,
			&artistTitle,
			&artistBrowseId,
		); err != nil {
			go logging.Logger.Error("Parsing of one playlist track failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Parsing of one playlist track failed.")
		}

		track, exists := tracks[playlistTrackId]
		if !exists {
			track = &commonpb.PlaylistTrack{
				PlaylistTrackId:    playlistTrackId,
				Title:              html.UnescapeString(title),
				Thumbnail:          thumbnail,
				PositionInPlaylist: position,
				IsExplicit:         &isExplicit,
				Duration:           duration,
				VideoId:            videoId,
				PlaylistId:         playlistId,
				Artists:            []*commonpb.EmbeddedArtist{},
			}

			if videoType == "uvideo" {
				track.VideoType = commonpb.VideoType_VIDEO_TYPE_UVIDEO
			} else {
				track.VideoType = commonpb.VideoType_VIDEO_TYPE_TRACK
			}

			tracks[playlistTrackId] = track
		}

		track.Artists = append(track.Artists, &commonpb.EmbeddedArtist{
			Title:    artistTitle,
			BrowseId: artistBrowseId,
		})
	}

	playlistTracks := make([]*commonpb.PlaylistTrack, 0, len(tracks))
	for _, t := range tracks {
		playlistTracks = append(playlistTracks, t)
	}

	return &playlistpb.GetPlaylistTracksResponse{
		PlaylistTracks: playlistTracks,
	}, nil
}
