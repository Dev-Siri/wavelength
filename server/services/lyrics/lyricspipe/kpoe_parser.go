package lyricspipe

import (
	"encoding/json"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
)

type kpoeResponse struct {
	KPoeTools string `json:"KpoeTools"`
	Type      string `json:"type"`
	Metadata  struct {
		Source      string         `json:"source"`
		SongWriters []string       `json:"songWriters"`
		Title       string         `json:"title"`
		Language    string         `json:"language"`
		Agents      map[string]any `json:"agents"`
		SongParts   []struct {
			Name     string `json:"name"`
			Time     int    `json:"time"`
			Duration int    `json:"duration"`
		} `json:"songParts"`
		TotalDuration string `json:"totalDuration"`
	} `json:"metadata"`
	Lyrics         []kpoeLyric `json:"lyrics"`
	Cached         string      `json:"cached"`
	ProcessingTime struct {
		TimeElapsed   int `json:"timeElapsed"`
		LastProcessed int `json:"lastProcessed"`
	} `json:"processingTime"`
}

type kpoeAltDataResponse struct {
	Data []kpoeLyric `json:"data"`
}

type kpoeAltNestedDataResponse struct {
	Data struct {
		Lyrics []kpoeLyric `json:"lyrics"`
	} `json:"data"`
}

type kpoeLyric struct {
	Time        int    `json:"time"`
	Duration    int    `json:"duration"`
	EndTime     int    `json:"endTime"`
	Text        string `json:"text"`
	Translation *struct {
		Text string `json:"text"`
	} `json:"translation"`
	Transliteration *struct {
		Text     string     `json:"text"`
		Syllabus []Syllable `json:"syllabus"`
	} `json:"transliteration"`
	Syllabus []struct {
		Time         int    `json:"time"`
		Duration     int    `json:"duration"`
		Text         string `json:"text"`
		Part         bool   `json:"part"`
		IsBackground bool   `json:"isBackground"`
	} `json:"syllabus"`
	Element any `json:"element"`
}

func parseKPoeLyrics(payloadBytes []byte) ([]*commonpb.LyricsLine, error) {
	var kpoe kpoeResponse
	if err := json.Unmarshal(payloadBytes, &kpoe); err != nil {
		return nil, err
	}

	rawLyrics, err := ensureLyricsSlice(payloadBytes, kpoe.Lyrics)
	if err != nil {
		return nil, err
	}

	if len(rawLyrics) == 0 {
		return nil, nil
	}

	lines := make([]*commonpb.LyricsLine, 0)

	// If type is 'Line', we revert to line-by-line highlighting by skipping syllabus parsing
	isLineType := kpoe.Type == "Line" || kpoe.Type == "line"
	// Convert metadata.agents to type map
	agentTypes := make(map[string]string)

	if kpoe.Metadata.Agents != nil {
		for k, v := range kpoe.Metadata.Agents {
			m, ok := v.(map[string]any)
			if !ok {
				continue
			}

			alias, _ := m["alias"].(string)
			typ, _ := m["type"].(string)

			if alias == "" {
				alias = k
			}
			agentTypes[alias] = typ
		}
	}

	lineSingers := make([]string, 0)
	for _, entry := range rawLyrics {
		element, _ := entry.Element.(map[string]any)
		var singer string
		if s, ok := element["singer"].(string); ok {
			singer = s
		}

		lineSingers = append(lineSingers, singer)
	}

	alignments := calculateLineAlignments(lineSingers, agentTypes)
	for i, entry := range rawLyrics {
		start := toMilliseconds(entry.Time, 0)
		duration := toMilliseconds(entry.Duration, 0)

		alignment := alignments[i]
		lineText := entry.Text
		lineStart := toMilliseconds(entry.Time, 0)
		lineDuration := toMilliseconds(entry.Duration, 0)
		explicitEnd := toMilliseconds(entry.EndTime, 0)

		var lineEnd int
		calculatedEnd := lineStart + lineDuration
		if explicitEnd != 0 {
			lineEnd = explicitEnd
		} else {
			lineEnd = calculatedEnd
		}

		syllabus := entry.Syllabus

		mainSyllables := make([]*commonpb.LyricsLine_Syllable, 0)
		backgroundSyllables := make([]*commonpb.LyricsLine_Syllable, 0)

		if !isLineType && len(syllabus) > 0 {
			for _, syl := range syllabus {
				sylStart := toMilliseconds(syl.Time, lineStart)
				sylDuration := toMilliseconds(syl.Duration, 0)

				var sylEnd int
				if sylDuration == 0 && len(syllabus) == 1 {
					sylEnd = lineEnd
				} else {
					sylEnd = sylStart + sylDuration
				}

				syllable := commonpb.LyricsLine_Syllable{
					Text:      syl.Text,
					Part:      syl.Part,
					Timestamp: uint64(sylStart),
					Endtime:   uint64(sylEnd),
				}

				if syl.IsBackground {
					backgroundSyllables = append(backgroundSyllables, &syllable)
				} else {
					mainSyllables = append(mainSyllables, &syllable)
				}
			}
		}

		if len(mainSyllables) == 0 && lineText != "" {
			mainSyllable := commonpb.LyricsLine_Syllable{
				Text:       lineText,
				Part:       false,
				Timestamp:  uint64(lineStart),
				LineSynced: &isLineType, // Mark as line-synced
			}

			if lineEnd != 0 {
				mainSyllable.Endtime = uint64(lineEnd)
			} else {
				mainSyllable.Endtime = uint64(lineStart)
			}

			mainSyllables = append(mainSyllables, &mainSyllable)
		}

		hasWordSync := len(mainSyllables) > 0 || len(backgroundSyllables) > 0

		var romanizedTextFromPayload *string

		if entry.Transliteration != nil {
			text := entry.Transliteration.Text
			romanizedTextFromPayload = &text

			// If syllabus data matches, map it to main syllables
			if len(entry.Transliteration.Syllabus) > 0 &&
				len(entry.Transliteration.Syllabus) == len(mainSyllables) {
				for i, s := range entry.Transliteration.Syllabus {
					mainSyllables[i].RomanizedText = &s.Text
				}
			}
		}

		var translationText *string
		if entry.Translation != nil && entry.Translation.Text != "" {
			translationText = &entry.Translation.Text
		}

		element, _ := entry.Element.(map[string]any)

		var songPart *string
		if sp, ok := element["songPart"].(string); ok {
			songPart = &sp
		}

		line := commonpb.LyricsLine{
			Text:           mainSyllables,
			Background:     len(backgroundSyllables) > 0,
			BackgroundText: backgroundSyllables,
			Timestamp:      uint64(lineStart),
			Endtime:        uint64(start + duration),
			Alignment:      alignment,
			SongPart:       songPart,
			RomanizedText:  romanizedTextFromPayload,
			Translation:    translationText,
		}

		if isLineType {
			isWordSynced := false
			line.IsWordSynced = &isWordSynced
		} else {
			line.IsWordSynced = &hasWordSync
		}

		oppositeTurn := alignment != nil && *alignment == commonpb.LyricsLine_ALIGNMENT_DIRECTION_END

		if !oppositeTurn {
			if arr, ok := any(entry.Element).([]string); ok {
				for _, v := range arr {
					if v == "opposite" || v == "right" {
						oppositeTurn = true
						break
					}
				}
			}
		}

		line.OppositeTurn = oppositeTurn

		lines = append(lines, &line)
	}

	return lines, nil
}

func ensureLyricsSlice(payloadBytes []byte, initial []kpoeLyric) ([]kpoeLyric, error) {
	if len(initial) > 0 {
		return initial, nil
	} else {
		var kpoeAlt kpoeAltDataResponse
		if err := json.Unmarshal(payloadBytes, &kpoeAlt); err != nil {
			return nil, err
		}

		if len(kpoeAlt.Data) > 0 {
			return kpoeAlt.Data, nil
		} else {
			var kpoeNestedAlt kpoeAltNestedDataResponse
			if err := json.Unmarshal(payloadBytes, &kpoeNestedAlt); err != nil {
				return nil, err
			}

			if len(kpoeNestedAlt.Data.Lyrics) > 0 {
				return kpoeNestedAlt.Data.Lyrics, nil
			}
		}
	}

	return nil, nil
}
