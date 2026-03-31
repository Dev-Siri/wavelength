package lyricspipe

import (
	"math"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
)

func calculateLineAlignments(lineSingers []string, agentTypes map[string]string) []*commonpb.LyricsLine_AlignmentDirection {
	lineSideAssignments := make([]*commonpb.LyricsLine_AlignmentDirection, len(lineSingers))

	var lastPersonSingerId *string
	currentSideIsLeft := true
	rightCount, totalCount := 0, 0

	for i, singerId := range lineSingers {
		var sideClass *commonpb.LyricsLine_AlignmentDirection

		if singerId != "" {
			agentType, exists := agentTypes[singerId]
			if !exists {
				if singerId == "v1000" {
					agentType = "group"
				} else if singerId == "v2000" {
					agentType = "other"
				} else {
					agentType = "person"
				}
			}

			if agentType == "group" {
				dir := commonpb.LyricsLine_ALIGNMENT_DIRECTION_START
				sideClass = &dir
			} else {
				if lastPersonSingerId == nil {
					currentSideIsLeft = agentType != "other"
				} else if singerId != *lastPersonSingerId {
					currentSideIsLeft = !currentSideIsLeft
				}

				if currentSideIsLeft {
					dir := commonpb.LyricsLine_ALIGNMENT_DIRECTION_START
					sideClass = &dir
				} else {
					dir := commonpb.LyricsLine_ALIGNMENT_DIRECTION_END
					sideClass = &dir
				}

				id := singerId
				lastPersonSingerId = &id
			}
		}

		if sideClass != nil {
			totalCount++
			if *sideClass == commonpb.LyricsLine_ALIGNMENT_DIRECTION_END {
				rightCount++
			}
		}

		lineSideAssignments[i] = sideClass
	}

	if totalCount > 0 && math.Round((float64(rightCount)/float64(totalCount))*100) >= 85 {
		for i, lineSideAssignment := range lineSideAssignments {
			lineSideAssignments[i] = flip(lineSideAssignment)
		}
	}

	return lineSideAssignments
}

func flip(s *commonpb.LyricsLine_AlignmentDirection) *commonpb.LyricsLine_AlignmentDirection {
	if s == nil {
		return s
	}

	if *s == commonpb.LyricsLine_ALIGNMENT_DIRECTION_START {
		dir := commonpb.LyricsLine_ALIGNMENT_DIRECTION_END
		return &dir
	}

	if *s == commonpb.LyricsLine_ALIGNMENT_DIRECTION_END {
		dir := commonpb.LyricsLine_ALIGNMENT_DIRECTION_START
		return &dir
	}

	return s
}
