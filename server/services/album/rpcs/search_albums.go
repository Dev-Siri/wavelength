package album_rpcs

import (
	"context"
	"wavelength/proto/albumpb"
	"wavelength/proto/yt_scraperpb"
	shared_clients "wavelength/shared/clients"
	"wavelength/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *AlbumService) SearchAlbums(
	ctx context.Context,
	request *albumpb.SearchAlbumsRequest,
) (*albumpb.SearchAlbumsResponse, error) {
	searchAlbumsResponse, err := shared_clients.YtScraperClient.SearchAlbums(ctx, &yt_scraperpb.SearchAlbumsRequest{
		Query: request.Query,
	})
	if err != nil {
		logging.Logger.Error("Albums search failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Albums search failed.")
	}

	return &albumpb.SearchAlbumsResponse{
		Albums: searchAlbumsResponse.Albums,
	}, nil
}
