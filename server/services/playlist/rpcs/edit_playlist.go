package playlist_rpcs

import (
	"context"
	"strconv"
	"wavelength/proto/playlistpb"
	shared_db "wavelength/shared/db"
	"wavelength/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (p *PlaylistService) EditPlaylist(
	ctx context.Context,
	request *playlistpb.EditPlaylistRequest,
) (*emptypb.Empty, error) {
	if request.PlaylistId == "" {
		return nil, status.Error(codes.InvalidArgument, "Playlist ID is required.")
	}

	// Build dynamic update query
	setClauses := []string{}
	args := []any{}
	argPos := 1

	if request.Name != "" {
		setClauses = append(setClauses, "name = $"+strconv.Itoa(argPos))
		args = append(args, request.Name)
		argPos++
	}

	if request.CoverImage != "" {
		setClauses = append(setClauses, "cover_image = $"+strconv.Itoa(argPos))
		args = append(args, request.CoverImage)
		argPos++
	}

	if len(setClauses) == 0 {
		return nil, status.Error(codes.InvalidArgument, "No fields provided for update.")
	}

	query := "UPDATE playlists SET " +
		func() string {
			s := ""
			for i, c := range setClauses {
				if i > 0 {
					s += ", "
				}
				s += c
			}
			return s
		}() +
		" WHERE playlist_id = $" + strconv.Itoa(argPos)

	args = append(args, request.PlaylistId)

	_, err := shared_db.Database.Exec(query, args...)
	if err != nil {
		logging.Logger.Error("Playlist edit failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Playlist edit failed.")
	}

	return &emptypb.Empty{}, nil
}
