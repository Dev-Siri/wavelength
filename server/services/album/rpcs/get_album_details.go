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

func (a *AlbumService) GetAlbumDetails(
	ctx context.Context,
	request *albumpb.GetAlbumDetailsRequest,
) (*albumpb.GetAlbumDetailsResponse, error) {
	albumDetailsResponse, err := clients.YtScraperClient.GetAlbumDetails(ctx, &yt_scraperpb.GetAlbumDetailsRequest{
		AlbumId: request.AlbumId,
	})
	if err != nil {
		logging.Logger.Error("Album details fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Album details fetch failed.")
	}

	return &albumpb.GetAlbumDetailsResponse{
		Album: albumDetailsResponse.Album,
	}, nil
}
