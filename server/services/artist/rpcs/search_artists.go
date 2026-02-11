package artist_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/artistpb"
	"github.com/Dev-Siri/wavelength/server/proto/yt_scraperpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *ArtistService) SearchArtists(
	ctx context.Context,
	request *artistpb.SearchArtistsRequest,
) (*artistpb.SearchArtistsResponse, error) {
	searchArtistsResponse, err := clients.YtScraperClient.SearchArtists(ctx, &yt_scraperpb.SearchArtistsRequest{
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
