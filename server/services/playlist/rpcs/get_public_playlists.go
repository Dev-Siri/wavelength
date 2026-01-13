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

func (p *PlaylistService) GetPublicPlaylists(
	ctx context.Context,
	request *playlistpb.GetPublicPlaylistsRequest,
) (*playlistpb.GetPublicPlaylistsResponse, error) {
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
		WHERE name ILIKE $1
		AND is_public = true 
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
