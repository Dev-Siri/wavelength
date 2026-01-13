package playlist_rpcs

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

func (p *PlaylistService) DeletePlaylist(
	ctx context.Context,
	request *playlistpb.DeletePlaylistRequest,
) (*emptypb.Empty, error) {
	row := shared_db.Database.QueryRow(`
		SELECT author_google_email FROM playlists
		WHERE playlist_id = $1
		LIMIT 1;
	`, request.PlaylistId)

	var playlistActualAuthorEmail string

	if err := row.Scan(&playlistActualAuthorEmail); err != nil {
		logging.Logger.Error("Database row scan failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Database row scan failed.")
	}

	if playlistActualAuthorEmail != request.AuthUserEmail {
		logging.Logger.Error("Deletion operation cannot be performed because the authorized user is not the author of the playlist.",
			zap.String("playlistId", request.PlaylistId),
			zap.String("authUserEmail", request.AuthUserEmail))
		return nil, status.Error(codes.Unauthenticated, "Deletion operation cannot be performed because the authorized user is not the author of the playlist.")
	}

	_, err := shared_db.Database.Exec(`
		DELETE FROM playlists
		WHERE playlist_id = $1;
	`, request.PlaylistId)

	if err != nil {
		logging.Logger.Error("Playlist deletion failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Playlist deletion failed.")
	}

	return &emptypb.Empty{}, nil
}
