package lyricspipe

import (
	"regexp"
	"strconv"
	"strings"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
)

var lrcMatchRegex = regexp.MustCompile(`^\[(\d{1,3}):(\d{2})\.(\d{2,3})\]\s?(.*)$`)

func parseLrcSubtitles(subtitles string) ([]*commonpb.LyricsLine, error) {
	type parsedLyric struct {
		Timestamp int
		Text      string
	}

	lines := make([]*commonpb.LyricsLine, 0)
	rawLines := strings.Split(subtitles, "\n")
	parsed := []parsedLyric{}

	for _, raw := range rawLines {
		matches := lrcMatchRegex.FindStringSubmatch(raw)
		if matches == nil {
			continue
		}

		minutes64, err := strconv.ParseInt(matches[1], 10, 64)
		if err != nil {
			return nil, err
		}
		seconds64, err := strconv.ParseInt(matches[2], 10, 64)
		if err != nil {
			return nil, err
		}
		centiseconds64, err := strconv.ParseInt(matches[3], 10, 64)
		if err != nil {
			return nil, err
		}

		minutes := int(minutes64)
		seconds := int(seconds64)
		centiseconds := int(centiseconds64)

		if len(matches[3]) == 3 {
			centiseconds = int((centiseconds + 5) / 10)
		}

		timestamp := (minutes*60+seconds)*1000 + centiseconds*10
		text := matches[4]
		if text == "" {
			text = ""
		}

		parsed = append(parsed, parsedLyric{
			Timestamp: timestamp,
			Text:      text,
		})
	}

	for i, parsedLyric := range parsed {
		var endtime uint64
		// Endtime is the start of the next line, or timestamp + 5s for the last line
		if i+1 < len(parsed) {
			endtime = uint64(parsed[i+1].Timestamp)
		} else {
			endtime = uint64(parsedLyric.Timestamp + 5000)
		}

		lineSynced := true
		syllable := &commonpb.LyricsLine_Syllable{
			Text:       parsedLyric.Text,
			Part:       false,
			Timestamp:  uint64(parsedLyric.Timestamp),
			Endtime:    endtime,
			LineSynced: &lineSynced,
		}

		isWordSynced := false
		lines = append(lines, &commonpb.LyricsLine{
			Text:           []*commonpb.LyricsLine_Syllable{syllable},
			Background:     false,
			BackgroundText: []*commonpb.LyricsLine_Syllable{},
			OppositeTurn:   false,
			Timestamp:      uint64(parsedLyric.Timestamp),
			Endtime:        endtime,
			IsWordSynced:   &isWordSynced,
		})
	}

	return lines, nil
}
