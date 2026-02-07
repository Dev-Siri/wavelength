package playlist_rpcs

import (
	"context"
	"database/sql"
	"html"
	"wavelength/proto/commonpb"
	"wavelength/proto/playlistpb"
	shared_type_constants "wavelength/shared/constants/types"
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
			a.browse_id AS artist_browse_id,
			al.title AS album_title,
			al.browse_id AS album_browse_id
		FROM "playlist_tracks" pt
		LEFT JOIN "artists" a
		ON pt.video_id = a.authored_track_id
		LEFT JOIN "albums" al
		ON pt.video_id = al.track_id
		WHERE pt.playlist_id = $1
	`, request.PlaylistId)

	if err != nil {
		logging.Logger.Error("Playlist tracks fetch failed.", zap.Error(err))
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
			albumTitle     sql.NullString
			albumBrowseId  sql.NullString
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
			&albumTitle,
			&albumBrowseId,
		); err != nil {
			logging.Logger.Error("Parsing of one playlist track failed.", zap.Error(err))
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
				VideoType:          shared_type_constants.PlaylistTrackTypeGrpcMap[shared_type_constants.PlaylistTrackType(videoType)],
			}

			if albumTitle.Valid && albumBrowseId.Valid {
				track.Album = &commonpb.EmbeddedAlbum{
					Title:    albumTitle.String,
					BrowseId: albumBrowseId.String,
				}
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
