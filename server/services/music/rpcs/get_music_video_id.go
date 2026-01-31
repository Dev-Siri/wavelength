package music_rpcs

import (
	"context"
	"fmt"
	"html"
	"strings"
	"wavelength/proto/musicpb"
	"wavelength/services/music/api"
	"wavelength/shared/logging"

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
	response, err := api.YouTubeV3Client.Search.List([]string{"id", "snippet"}).
		Q(q).
		VideoCategoryId("10").
		MaxResults(15).
		Type("video").
		Order("viewCount").
		Do()

	if err != nil {
		logging.Logger.Error("Music video fetch from YouTube failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Music video fetch from YouTube failed.")
	}

	type SearchableYouTubeVideo struct {
		VideoID string
		Title   string
		Channel string
	}

	videos := []SearchableYouTubeVideo{}

	for _, item := range response.Items {
		if !strings.Contains(item.Snippet.Title, request.Title) {
			continue
		}

		videos = append(videos, SearchableYouTubeVideo{
			VideoID: item.Id.VideoId,
			Title:   item.Snippet.Title,
			Channel: item.Snippet.ChannelTitle,
		})
	}

	if len(videos) == 0 {
		return nil, status.Error(codes.NotFound, "No suitable music video found.")
	}

	keyword := fmt.Sprintf("%s %s official music video", request.Artist, request.Title)
	titles := make([]string, len(videos))

	for i, v := range videos {
		titles[i] = strings.ToLower(
			html.UnescapeString(v.Title) + " " + v.Channel,
		)
	}

	matches := fuzzy.Find(strings.ToLower(keyword), titles)

	var selectedVideo SearchableYouTubeVideo

	if len(matches) > 0 {
		selectedVideo = videos[matches[0].Index]
	} else {
		// Fallback.
		selectedVideo = videos[0]
	}

	return &musicpb.GetMusicVideoIdResponse{
		VideoId: selectedVideo.VideoID,
	}, nil
}
