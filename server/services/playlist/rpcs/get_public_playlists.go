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

func (p *PlaylistService) GetPublicPlaylists(
	ctx context.Context,
	request *playlistpb.GetPublicPlaylistsRequest,
) (*playlistpb.GetPublicPlaylistsResponse, error) {
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
		WHERE p.name ILIKE $1
		AND p.is_public = true 
		INNER JOIN "users" u
		ON u.email = p.author_google_email
		LIMIT 10;
	`, "%"+request.Query+"%")

	if err != nil {
		logging.Logger.Error("Public playlists fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Public playlists fetch failed.")
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
			logging.Logger.Error("Parsing one of public playlists failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Parsing one of public playlists failed.")
		}

		playlists = append(playlists, &playlist)
	}

	return &playlistpb.GetPublicPlaylistsResponse{
		Playlists: playlists,
	}, nil
}
