package music_rpcs

import (
	"context"
	"encoding/json"
	"strings"

	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/proto/yt_scraperpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	shared_constants "github.com/Dev-Siri/wavelength/server/shared/constants"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/redis/go-redis/v9"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (m *MusicService) GetMusicSearchSuggestions(
	ctx context.Context,
	request *musicpb.GetMusicSearchSuggestionsRequest,
) (*musicpb.GetMusicSearchSuggestionsResponse, error) {
	cachedSuggestions := fetchCachedSuggestions(ctx, request.Query)
	if cachedSuggestions != nil {
		return cachedSuggestions, nil
	}

	searchSuggestionsResponse, err := clients.YtScraperClient.GetSearchSuggestions(ctx, &yt_scraperpb.GetSearchSuggestionsRequest{
		Query: request.Query,
	})
	if err != nil {
		logging.Logger.Error("Search results fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Search results fetch failed.")
	}

	matchingLinks := []*musicpb.GetMusicSearchSuggestionsResponse_SearchSuggestedLink{}

	for _, item := range searchSuggestionsResponse.SuggestedLinks {
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

	response := &musicpb.GetMusicSearchSuggestionsResponse{
		MatchingQueries: searchSuggestionsResponse.SuggestedQueries,
		MatchingLinks:   matchingLinks,
	}

	if err := saveSuggestionsToCache(ctx, request.Query, response); err != nil {
		logging.Logger.Error("Search suggestions save to cache failed.", zap.Error(err), zap.String("q", request.Query))
	}

	return response, nil
}

func fetchCachedSuggestions(ctx context.Context, q string) *musicpb.GetMusicSearchSuggestionsResponse {
	cachedSuggestionsResponse, err := shared_db.Redis.JSONGet(ctx, q, "$").Result()
	if err == redis.Nil {
		return nil
	}

	if err != nil {
		logging.Logger.Error("Search suggestions fetch from cache failed.", zap.Error(err), zap.String("q", q))
		return nil
	}

	var response musicpb.GetMusicSearchSuggestionsResponse
	if err := json.Unmarshal([]byte(cachedSuggestionsResponse), &response); err != nil {
		logging.Logger.Error("Search suggestions cache decode failed.", zap.Error(err))
		return nil
	}

	return &response
}

func saveSuggestionsToCache(
	ctx context.Context,
	q string,
	response *musicpb.GetMusicSearchSuggestionsResponse,
) error {
	_, err := shared_db.Redis.JSONSet(ctx, shared_constants.MusicSearchSuggestionsKey.K(q), "$", response).Result()
	return err
}
