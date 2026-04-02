package lyrics_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/lyricspb"
	"github.com/Dev-Siri/wavelength/server/services/lyrics/google"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func TranslateLyrics(
	ctx context.Context,
	request *lyricspb.TranslateLyricsRequest,
) (*lyricspb.TranslateLyricsResponse, error) {
	translatedLyrics, err := google.Translate(request.TextToTranslate, request.Language)
	if err != nil {
		logging.Logger.Error("Lyrics translation failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Lyrics translation failed.")
	}

	return &lyricspb.TranslateLyricsResponse{
		Translations: translatedLyrics,
	}, nil

}
