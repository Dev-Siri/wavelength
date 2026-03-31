package lyrics_rpcs

import (
	"context"

	lyricspb "github.com/Dev-Siri/wavelength/server/proto/lyricspb"
	"github.com/Dev-Siri/wavelength/server/proto/yt_scraperpb"
	"github.com/Dev-Siri/wavelength/server/services/lyrics/lyricspipe"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/Dev-Siri/wavelength/server/utils"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (l *LyricService) GetTrackLyrics(
	ctx context.Context,
	request *lyricspb.GetTrackLyricsRequest,
) (*lyricspb.GetTrackLyricsResponse, error) {
	trackResponse, err := clients.YtScraperClient.GetTrackInfo(ctx, &yt_scraperpb.GetTrackInfoRequest{
		VideoId: request.VideoId,
	})
	if err != nil {
		logging.Logger.Error("Track info fetch failed.", zap.Error(err))
		return nil, err
	}

	lyrics, err := lyricspipe.FetchLyrics(
		trackResponse.Track.Title,
		utils.FormatAndJoinArtists(trackResponse.Track.Artists),
		trackResponse.Track.Album.Title,
		float64(trackResponse.Track.Duration*1000),
	)
	if err != nil {
		logging.Logger.Error("Lyrics fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Lyrics fetch failed.")
	}

	if len(lyrics) == 0 {
		logging.Logger.Error("No lyrics found.")
		return nil, status.Error(codes.NotFound, "No lyrics found.")
	}

	return &lyricspb.GetTrackLyricsResponse{
		Source: lyrics[0].Source,
		Lines:  lyrics[0].Lines,
	}, nil
}
