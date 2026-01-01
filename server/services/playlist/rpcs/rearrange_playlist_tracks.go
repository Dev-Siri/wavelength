package rpcs

import (
	"context"
	"wavelength/proto/playlistpb"
	shared_db "wavelength/shared/db"
	"wavelength/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (p *PlaylistService) RearrangePlaylistTracks(
	ctx context.Context,
	request *playlistpb.RearrangePlaylistTracksRequest,
) (*emptypb.Empty, error) {
	tx, err := shared_db.Database.Begin()
	if err != nil {
		go logging.Logger.Error("Transaction start failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Transaction start failed.")
	}

	defer tx.Rollback()

	stmt, err := tx.Prepare(`
		UPDATE playlist_tracks
		SET position_in_playlist = $1
		WHERE playlist_id = $2 AND playlist_track_id = $3
	`)

	if err != nil {
		go logging.Logger.Error("Statement preparation failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Statement preparation failed.")
	}

	defer stmt.Close()

	for _, pos := range request.Updates {
		if _, err := stmt.Exec(pos.NewPos, request.PlaylistId, pos.PlaylistTrackId); err != nil {
			go logging.Logger.Error("Playlist positions update failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Playlist positions update failed.")
		}
	}

	if err := tx.Commit(); err != nil {
		go logging.Logger.Error("Transaction commit failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Transaction commit failed.")
	}

	return &emptypb.Empty{}, nil
}
