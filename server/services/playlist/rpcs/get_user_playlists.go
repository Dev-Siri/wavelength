package playlist_rpcs

import (
	"context"
	"wavelength/proto/commonpb"
	"wavelength/proto/playlistpb"
	shared_db "wavelength/shared/db"
	"wavelength/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (p *PlaylistService) GetUserPlaylists(
	ctx context.Context,
	request *playlistpb.GetUserPlaylistsRequest,
) (*playlistpb.GetUserPlaylistsResponse, error) {
	rows, err := shared_db.Database.Query(`
		SELECT
			playlist_id,
			name,
			author_google_email,
			author_name,
			author_image,
			cover_image,
			is_public
		FROM playlists
		WHERE author_google_email = $1
	`, request.UserEmail)
	if err != nil {
		logging.Logger.Error("Playlists fetched failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Playlists fetch failed.")
	}

	playlists := make([]*commonpb.Playlist, 0)

	for rows.Next() {
		var playlist commonpb.Playlist

		if err := rows.Scan(
			&playlist.PlaylistId,
			&playlist.Name,
			&playlist.AuthorGoogleEmail,
			&playlist.AuthorName,
			&playlist.AuthorImage,
			&playlist.CoverImage,
			&playlist.IsPublic,
		); err != nil {
			logging.Logger.Error("Parsing of one playlist failed", zap.Error(err))
			return nil, status.Error(codes.Internal, "Parsing of one playlist failed")
		}

		playlists = append(playlists, &playlist)
	}

	return &playlistpb.GetUserPlaylistsResponse{
		Playlists: playlists,
	}, nil
}
