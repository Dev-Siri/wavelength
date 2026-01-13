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

func (a *AlbumService) GetAlbumDetails(
	ctx context.Context,
	request *albumpb.GetAlbumDetailsRequest,
) (*albumpb.GetAlbumDetailsResponse, error) {
	albumDetailsResponse, err := shared_clients.YtScraperClient.GetAlbumDetails(ctx, &yt_scraperpb.GetAlbumDetailsRequest{
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
