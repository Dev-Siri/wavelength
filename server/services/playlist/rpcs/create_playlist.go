package playlist_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/google/uuid"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (p *PlaylistService) CreatePlaylist(
	ctx context.Context,
	request *playlistpb.CreatePlaylistRequest,
) (*emptypb.Empty, error) {
	playlistId := uuid.NewString()

	_, err := shared_db.Database.Exec(`
		INSERT INTO playlists (
			playlist_id,
			name,
			author_google_email,
			author_name,
			author_image,
			cover_image
		)
		VALUES ( $1, $2, $3, $4, $5, $6 );
	`, playlistId, "New Playlist", request.AuthorEmail, request.AuthorDisplayName, request.AuthorPhotoUrl, nil)

	if err != nil {
		logging.Logger.Error("Playlist creation failed.", zap.Error(err), zap.String("author_email", request.AuthorEmail))
		return nil, status.Error(codes.Internal, "Playlist creation failed. ")
	}

	return &emptypb.Empty{}, nil
}
