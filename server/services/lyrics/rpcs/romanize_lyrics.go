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

func RomanizeLyrics(
	ctx context.Context,
	request *lyricspb.RomanizeLyricsRequest,
) (*lyricspb.RomanizeLyricsResponse, error) {
	romanizedLines, err := google.Romanize(request.Lyrics)
	if err != nil {
		logging.Logger.Error("Lyrics romanization failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Lyrics romanization failed.")
	}

	return &lyricspb.RomanizeLyricsResponse{
		RomanizedLines: romanizedLines,
	}, nil
}
