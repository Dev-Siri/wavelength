package lyricspipe

import (
	"sort"
	"strings"
)

func mergeAndSortSources(collectedSources []YouLyPlusLyricsResult) []YouLyPlusLyricsResult {
	uniqueSourcesMap := make(map[string]YouLyPlusLyricsResult)

	for _, source := range collectedSources {
		fetchSource := strings.ToLower(source.Source)

		var normalizedSource string
		if strings.Contains(fetchSource, "lyricsplus") {
			normalizedSource = "QQ"
		} else {
			normalizedSource = source.Source
		}

		_, inMap := uniqueSourcesMap[normalizedSource]
		if !inMap {
			uniqueSourcesMap[normalizedSource] = YouLyPlusLyricsResult{
				Source: normalizedSource,
				Lines:  source.Lines,
			}
		}
	}

	finalizedSources := make([]YouLyPlusLyricsResult, 0)
	for _, v := range uniqueSourcesMap {
		finalizedSources = append(finalizedSources, v)
	}

	sort.Slice(finalizedSources, func(i, j int) bool {
		return getRankForCollected(finalizedSources[i].Source, finalizedSources[i].Lines) <
			getRankForCollected(finalizedSources[j].Source, finalizedSources[j].Lines)
	})

	return finalizedSources
}
