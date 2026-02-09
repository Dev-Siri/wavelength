package music_rpcs

import (
	"context"
	"html"
	"wavelength/proto/commonpb"
	"wavelength/proto/musicpb"
	"wavelength/proto/yt_scraperpb"
	shared_clients "wavelength/shared/clients"
	"wavelength/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (m *MusicService) SearchYouTubeVideos(
	ctx context.Context,
	request *musicpb.SearchYouTubeVideosRequest,
) (*musicpb.SearchYouTubeVideosResponse, error) {
	videosResponse, err := shared_clients.YtScraperClient.SearchYouTubeVideos(ctx, &yt_scraperpb.SearchYouTubeVideosRequest{
		Query: request.Query,
	})
	if err != nil {
		logging.Logger.Error("YouTube videos fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "YouTube videos fetch failed.")
	}

	if len(videosResponse.Videos) == 0 {
		return nil, status.Error(codes.NotFound, "No search results for that query.")
	}

	youtubeVideos := make([]*commonpb.YouTubeVideo, len(videosResponse.Videos))

	for _, ytVideo := range videosResponse.Videos {
		video := commonpb.YouTubeVideo{
			VideoId:         ytVideo.VideoId,
			Title:           html.UnescapeString(ytVideo.Title),
			Thumbnail:       ytVideo.Thumbnail,
			Author:          ytVideo.Author,
			AuthorChannelId: ytVideo.AuthorChannelId,
		}

		youtubeVideos = append(youtubeVideos, &video)
	}

	return &musicpb.SearchYouTubeVideosResponse{
		YoutubeVideos: youtubeVideos,
	}, nil
}
