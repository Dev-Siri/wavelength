package music_rpcs

import (
	"context"
	"fmt"
	"html"
	"strings"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/proto/yt_scraperpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/sahilm/fuzzy"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (m *MusicService) GetMusicVideoId(
	ctx context.Context,
	request *musicpb.GetMusicVideoIdRequest,
) (*musicpb.GetMusicVideoIdResponse, error) {
	q := fmt.Sprintf("%s %s (Official Music Video)", request.Artist, request.Title)
	videosResponse, err := clients.YtScraperClient.SearchYouTubeVideos(ctx, &yt_scraperpb.SearchYouTubeVideosRequest{
		Query: q,
	})
	if err != nil {
		logging.Logger.Error("Music video fetch from YouTube failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Music video fetch from YouTube failed.")
	}

	videos := videosResponse.Videos

	if len(videos) == 0 {
		return nil, status.Error(codes.NotFound, "No suitable music video found.")
	}

	keyword := fmt.Sprintf("%s %s official music video", request.Artist, request.Title)
	titles := make([]string, len(videos))

	for i, v := range videos {
		titles[i] = strings.ToLower(
			html.UnescapeString(v.Title) + " " + v.Author,
		)
	}

	matches := fuzzy.Find(strings.ToLower(keyword), titles)

	var selectedVideo *commonpb.YouTubeVideo

	if len(matches) > 0 {
		selectedVideo = videos[matches[0].Index]
	} else {
		// Fallback.
		selectedVideo = videos[0]
	}

	return &musicpb.GetMusicVideoIdResponse{
		VideoId: selectedVideo.VideoId,
	}, nil
}
