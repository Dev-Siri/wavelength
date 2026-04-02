package lyricspipe

import (
	"strings"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
)

func getRank(sourceLabel string, parsedLines []*commonpb.LyricsLine) int {
	lower := strings.ToLower(sourceLabel)

	hasWordSync := false

	for _, line := range parsedLines {
		if len(line.Text) > 1 {
			hasWordSync = true
			break
		}
	}

	isUnsynced := len(parsedLines) > 0

	for _, line := range parsedLines {
		if !(line.Timestamp == 0 && line.Endtime == 0) {
			isUnsynced = false
			break
		}
	}

	isQQ := strings.Contains(lower, "qq") || strings.Contains(lower, "lyricsplus")

	if strings.Contains(lower, "apple") && hasWordSync {
		return 1
	}
	if isQQ && hasWordSync {
		return 2
	}
	if strings.Contains(lower, "musixmatch") && hasWordSync {
		return 3
	}

	if strings.Contains(lower, "apple") && !hasWordSync && !isUnsynced {
		return 4
	}
	if isQQ && !hasWordSync && !isUnsynced {
		return 5
	}
	if strings.Contains(lower, "musixmatch") && !hasWordSync && !isUnsynced {
		return 6
	}

	if strings.Contains(lower, "apple") && isUnsynced {
		return 7
	}
	if isQQ && isUnsynced {
		return 8
	}
	if strings.Contains(lower, "musixmatch") && isUnsynced {
		return 9
	}

	return 10
}

func getRankForCollected(sourceLabel string, parsedLines []*commonpb.LyricsLine) int {
	lower := strings.ToLower(sourceLabel)

	hasWordSync := false
	for _, line := range parsedLines {
		if len(line.Text) > 1 {
			hasWordSync = true
			break
		}
	}

	isUnsynced := len(parsedLines) > 0
	for _, line := range parsedLines {
		if !(line.Timestamp == 0 && line.Endtime == 0) {
			isUnsynced = false
			break
		}
	}

	isQQ := strings.Contains(lower, "qq") || strings.Contains(lower, "lyricsplus")

	if strings.Contains(lower, "apple") && hasWordSync {
		return 1
	}
	if isQQ && hasWordSync {
		return 2
	}
	if strings.Contains(lower, "musixmatch") && hasWordSync {
		return 3
	}
	if strings.Contains(lower, "tidal") && hasWordSync {
		return 4
	}
	if strings.Contains(lower, "lrclib") && hasWordSync {
		return 5
	}

	if strings.Contains(lower, "apple") && !hasWordSync && !isUnsynced {
		return 6
	}
	if isQQ && !hasWordSync && !isUnsynced {
		return 7
	}
	if strings.Contains(lower, "musixmatch") && !hasWordSync && !isUnsynced {
		return 8
	}
	if strings.Contains(lower, "tidal") && !hasWordSync && !isUnsynced {
		return 9
	}
	if strings.Contains(lower, "lrclib") && !hasWordSync && !isUnsynced {
		return 10
	}

	if strings.Contains(lower, "apple") && isUnsynced {
		return 11
	}
	if isQQ && isUnsynced {
		return 12
	}
	if strings.Contains(lower, "musixmatch") && isUnsynced {
		return 13
	}
	if strings.Contains(lower, "tidal") && isUnsynced {
		return 14
	}
	if strings.Contains(lower, "lrclib") && isUnsynced {
		return 15
	}
	if strings.Contains(lower, "genius") {
		return 16
	}

	return 20
}
