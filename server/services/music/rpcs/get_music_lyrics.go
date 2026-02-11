package music_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/services/music/api"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (m *MusicService) GetMusicLyrics(
	ctx context.Context,
	request *musicpb.GetMusicLyricsRequest,
) (*musicpb.GetMusicLyricsResponse, error) {
	spotifyTrackId, err := api.Lyrics.GetTrackSpotifyID(request.Title, request.Artist)
	if err != nil {
		logging.Logger.Error("Spotify Track ID fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Spotify Track ID fetch failed.")
	}

	lyrics, err := api.Lyrics.GetTrackLyrics(spotifyTrackId)
	if err != nil {
		logging.Logger.Error("Lyrics fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Lyrics fetch failed.")
	}

	return &musicpb.GetMusicLyricsResponse{
		Lyrics: lyrics,
	}, nil
}
