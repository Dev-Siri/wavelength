package artist_rpcs

import (
	"context"
	"wavelength/proto/artistpb"
	"wavelength/proto/yt_scraperpb"
	shared_clients "wavelength/shared/clients"
	"wavelength/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *ArtistService) SearchArtists(
	ctx context.Context,
	request *artistpb.SearchArtistsRequest,
) (*artistpb.SearchArtistsResponse, error) {
	searchArtistsResponse, err := shared_clients.YtScraperClient.SearchArtists(ctx, &yt_scraperpb.SearchArtistsRequest{
		Query: request.Query,
	})
	if err != nil {
		logging.Logger.Error("Artists search failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Artists search failed.")
	}

	return &artistpb.SearchArtistsResponse{
		Artists: searchArtistsResponse.Artists,
	}, nil
}
