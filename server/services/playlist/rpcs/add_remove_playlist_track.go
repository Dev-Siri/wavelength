package playlist_rpcs

import (
	"context"
	"database/sql"
	"errors"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_musicmeta "github.com/Dev-Siri/wavelength/server/shared/musicmeta"

	"github.com/google/uuid"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (p *PlaylistService) AddRemovePlaylistTrack(
	ctx context.Context,
	request *playlistpb.AddRemovePlaylistTrackRequest,
) (*playlistpb.AddRemovePlaylistTrackResponse, error) {
	var songCount int
	err := shared_db.Database.QueryRow(`
		SELECT COUNT(*) 
		FROM playlist_tracks 
		WHERE playlist_id = $1 AND video_id = $2`,
		request.PlaylistId, request.VideoId).Scan(&songCount)

	if err != nil {
		logging.Logger.Error("Check for existing track failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Check for existing track failed.")
	}

	if songCount > 0 {
		_, err := shared_db.Database.Exec(`
			DELETE FROM playlist_tracks 
			WHERE playlist_id = $1 AND video_id = $2
		`, request.PlaylistId, request.VideoId)

		if err != nil {
			logging.Logger.Error("Track removal failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Track removal failed. ")
		}

		return &playlistpb.AddRemovePlaylistTrackResponse{
			ToggleType: playlistpb.AddRemovePlaylistTrackResponse_PLAYLIST_TRACK_TOGGLE_TYPE_REMOVE,
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

	var totalSongCount int
	err = shared_db.Database.QueryRow(`
		SELECT COUNT(*) 
		FROM playlist_tracks 
		WHERE playlist_id = $1`,
		request.PlaylistId).Scan(&totalSongCount)

	if err != nil && !errors.Is(err, sql.ErrNoRows) {
		logging.Logger.Error("Playlist track count fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Playlist track count fetch failed")
	}

	playlistTrackId := uuid.NewString()

	dbVideoType := "track"
	if request.VideoType == commonpb.VideoType_VIDEO_TYPE_UVIDEO {
		dbVideoType = "uvideo"
	}

	_, err = shared_db.Database.Exec(`
		INSERT INTO playlist_tracks (
			title,
			thumbnail,
			duration,
			is_explicit,
			video_id,
			video_type,
			playlist_id, 
			playlist_track_id, 
			position_in_playlist
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9 )`,
		request.Title,
		request.Thumbnail,
		request.Duration,
		request.IsExplicit,
		request.VideoId,
		dbVideoType,
		request.PlaylistId, playlistTrackId, totalSongCount+1,
	)

	if err != nil {
		logging.Logger.Error("Playlist track addition failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Playlist track addition failed.")
	}

	return &playlistpb.AddRemovePlaylistTrackResponse{
		ToggleType: playlistpb.AddRemovePlaylistTrackResponse_PLAYLIST_TRACK_TOGGLE_TYPE_ADD,
	}, nil
}
