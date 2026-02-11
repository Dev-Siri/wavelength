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

func (p *PlaylistService) GetPlaylistById(
	ctx context.Context,
	request *playlistpb.GetPlaylistByIdRequest,
) (*playlistpb.GetPlaylistByIdResponse, error) {
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
		WHERE playlist_id = $1
		LIMIT 1;
	`, request.PlaylistId)
	if err != nil {
		logging.Logger.Error("Playlist fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Playlist fetch failed.")
	}

	var playlist *commonpb.Playlist

	for rows.Next() {
		playlist = &commonpb.Playlist{}

		if err := rows.Scan(
			&playlist.PlaylistId,
			&playlist.Name,
			&playlist.AuthorGoogleEmail,
			&playlist.AuthorName,
			&playlist.AuthorImage,
			&playlist.CoverImage,
			&playlist.IsPublic,
		); err != nil {
			logging.Logger.Error("Playlist parse failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Playlist parse failed.")
		}
	}

	if playlist == nil {
		return nil, status.Error(codes.NotFound, "Playlist not found.")
	}

	return &playlistpb.GetPlaylistByIdResponse{Playlist: playlist}, nil
}
