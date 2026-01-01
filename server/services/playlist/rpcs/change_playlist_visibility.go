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

func (p *PlaylistService) ChangePlaylistVisibility(
	ctx context.Context,
	request *playlistpb.ChangePlaylistVisibilityRequest,
) (*emptypb.Empty, error) {
	row := shared_db.Database.QueryRow(`
		SELECT author_google_email FROM playlists
		WHERE playlist_id = $1
		LIMIT 1;
	`, request.PlaylistId)

	var playlistActualAuthorEmail string

	if err := row.Scan(&playlistActualAuthorEmail); err != nil {
		go logging.Logger.Error("Database row scan failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Database row scan failed.")
	}

	if playlistActualAuthorEmail != request.AuthUserEmail {
		go logging.Logger.Error("Visibility change cannot be performed because the authorized user is not the author of the playlist.",
			zap.String("playlistId", request.PlaylistId),
			zap.String("authUserEmail", request.AuthUserEmail))
		return nil, status.Error(codes.Unauthenticated, "Visibility change cannot be performed because the authorized user is not the author of the playlist.")
	}

	rows, err := shared_db.Database.Query(`
		SELECT is_public FROM playlists
		WHERE playlist_id = $1;
	`, request.PlaylistId)

	if err != nil {
		go logging.Logger.Error("Playlist visibility change failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Playlist visibility change failed.")
	}

	var isPublic bool

	for rows.Next() {
		if err := rows.Scan(&isPublic); err != nil {
			go logging.Logger.Error("Playlist visibility change failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Playlist visibility change failed.")
		}
	}

	_, err = shared_db.Database.Exec(`
		UPDATE playlists
		SET is_public = $1
		WHERE playlist_id = $2;
	`, !isPublic, request.PlaylistId)

	if err != nil {
		go logging.Logger.Error("Playlist visibility change failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Playlist visibility change failed.")
	}

	return &emptypb.Empty{}, nil
}
