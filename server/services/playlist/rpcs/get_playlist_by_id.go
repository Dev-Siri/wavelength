package playlist_rpcs

import (
	"context"
	"database/sql"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (p *PlaylistService) GetPlaylistById(
	ctx context.Context,
	request *playlistpb.GetPlaylistByIdRequest,
) (*playlistpb.GetPlaylistByIdResponse, error) {
	row := shared_db.Database.QueryRow(`
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
		WHERE p.playlist_id = $1;
	`, request.PlaylistId)

	var playlist commonpb.Playlist

	if err := row.Scan(
		&playlist.PlaylistId,
		&playlist.Name,
		&playlist.AuthorGoogleEmail,
		&playlist.CoverImage,
		&playlist.IsPublic,
		&playlist.AuthorName,
		&playlist.AuthorImage,
	); err != nil {
		if err == sql.ErrNoRows {
			return nil, status.Error(codes.NotFound, "Playlist not found.")
		}

		logging.Logger.Error("Playlist fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Playlist fetch failed.")
	}

	return &playlistpb.GetPlaylistByIdResponse{
		Playlist: &playlist,
	}, nil
}
