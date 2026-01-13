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

func (s *ArtistService) GetArtistDetails(
	ctx context.Context,
	request *artistpb.GetArtistDetailsRequest,
) (*artistpb.GetArtistDetailsResponse, error) {
	artistDetailsResponse, err := shared_clients.YtScraperClient.GetArtistDetails(ctx, &yt_scraperpb.GetArtistDetailsRequest{
		BrowseId: request.BrowseId,
	})
	if err != nil {
		logging.Logger.Error("Artist details fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Artist details fetch failed.")
	}

	return &artistpb.GetArtistDetailsResponse{
		Artist: artistDetailsResponse.Artist,
	}, nil
}
