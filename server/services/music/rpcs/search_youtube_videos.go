package music_rpcs

import (
	"context"
	"html"
	"wavelength/proto/commonpb"
	"wavelength/proto/musicpb"
	"wavelength/services/music/api"
	"wavelength/services/music/utils"
	"wavelength/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (m *MusicService) SearchYouTubeVideos(
	ctx context.Context,
	request *musicpb.SearchYouTubeVideosRequest,
) (*musicpb.SearchYouTubeVideosResponse, error) {
	searchResults, err := api.YouTubeV3Client.Search.List([]string{"snippet"}).Q(request.Query).MaxResults(20).Do()

	if err != nil {
		logging.Logger.Error("YouTube videos search fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "YouTube videos search fetch failed.")
	}

	if len(searchResults.Items) == 0 {
		return nil, status.Error(codes.NotFound, "No search results for that query.")
	}

	var youtubeVideos []*commonpb.YouTubeVideo

	for _, item := range searchResults.Items {
		if item.Id.VideoId == "" {
			continue
		}

		video := commonpb.YouTubeVideo{
			VideoId:         item.Id.VideoId,
			Title:           html.UnescapeString(item.Snippet.Title),
			Thumbnail:       utils.GetHighestPossibleThumbnailUrl(item.Snippet.Thumbnails),
			Author:          item.Snippet.ChannelTitle,
			AuthorChannelId: item.Snippet.ChannelId,
		}

		youtubeVideos = append(youtubeVideos, &video)
	}

	return &musicpb.SearchYouTubeVideosResponse{
		YoutubeVideos: youtubeVideos,
	}, nil
}
