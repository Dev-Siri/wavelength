package album_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	"github.com/Dev-Siri/wavelength/server/proto/yt_scraperpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *AlbumService) SearchAlbums(
	ctx context.Context,
	request *albumpb.SearchAlbumsRequest,
) (*albumpb.SearchAlbumsResponse, error) {
	searchAlbumsResponse, err := clients.YtScraperClient.SearchAlbums(ctx, &yt_scraperpb.SearchAlbumsRequest{
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
