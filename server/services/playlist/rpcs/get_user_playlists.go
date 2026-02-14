package playlist_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

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
			p.playlist_id,
			p.name,
			p.author_google_email,
			p.cover_image,
			p.is_public,

			u.display_name AS author_name,
			u.picture_url AS author_image
		FROM "playlists" p
		INNER JOIN "users" u
		ON u.email = p.author_google_email
		WHERE p.author_google_email = $1
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
			&playlist.CoverImage,
			&playlist.IsPublic,
			&playlist.AuthorName,
			&playlist.AuthorImage,
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
