package music_rpcs

import (
	"context"
	"strings"
	"wavelength/proto/musicpb"
	"wavelength/proto/yt_scraperpb"
	shared_clients "wavelength/shared/clients"
	"wavelength/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (m *MusicService) GetMusicSearchSuggestions(
	ctx context.Context,
	request *musicpb.GetMusicSearchSuggestionsRequest,
) (*musicpb.GetMusicSearchSuggestionsResponse, error) {
	response, err := shared_clients.YtScraperClient.GetSearchSuggestions(ctx, &yt_scraperpb.GetSearchSuggestionsRequest{
		Query: request.Query,
	})
	if err != nil {
		logging.Logger.Error("Search results fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Search results fetch failed.")
	}

	matchingLinks := []*musicpb.GetMusicSearchSuggestionsResponse_SearchSuggestedLink{}

	for _, item := range response.SuggestedLinks {
		subtitleParts := strings.Split(item.Subtitle, " • ")

		if len(subtitleParts) < 3 {
			logging.Logger.Error("Subtitle does not contain all parts (3)", zap.String("subtitle", item.Subtitle))
			// It's invalid, so we skip it here.
			continue
		}

		meta := musicpb.GetMusicSearchSuggestionsResponse_SearchSuggestedLink_SearchSuggestedLinkMeta{
			Type:                subtitleParts[0],
			AuthorOrAlbum:       subtitleParts[1],
			PlaysOrAlbumRelease: subtitleParts[2],
		}

		suggestedLink := musicpb.GetMusicSearchSuggestionsResponse_SearchSuggestedLink{
			Meta:      &meta,
			Title:     item.Title,
			Subtitle:  item.Subtitle,
			Thumbnail: item.Thumbnail,
			BrowseId:  item.BrowseId,
			Type:      item.Type,
		}

		matchingLinks = append(matchingLinks, &suggestedLink)
	}

	return &musicpb.GetMusicSearchSuggestionsResponse{
		MatchingQueries: response.SuggestedQueries,
		MatchingLinks:   matchingLinks,
	}, nil
}
