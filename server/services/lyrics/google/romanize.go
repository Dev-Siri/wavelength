package google

import (
	"encoding/json"
	"math"
	"net/http"
	"strings"
	"time"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/protobuf/proto"
)

func Romanize(originalLyrics []*commonpb.LyricsLine) ([]*commonpb.LyricsLine, error) {
	isWordSynced := false
	for _, line := range originalLyrics {
		if line.IsWordSynced != nil && *line.IsWordSynced && len(line.Text) > 1 {
			isWordSynced = true
			break
		}
	}

	if isWordSynced {
		return romanizeWordSynced(originalLyrics)
	}

	return romanizeLineSynced(originalLyrics)
}

func romanizeWordSynced(lines []*commonpb.LyricsLine) ([]*commonpb.LyricsLine, error) {
	finalLines := make([]*commonpb.LyricsLine, len(lines))
	copy(finalLines, lines)

	for i, line := range finalLines {
		if line == nil || len(line.Text) == 0 || line.RomanizedText != nil {
			continue
		}

		var builder strings.Builder
		for _, s := range line.Text {
			builder.WriteString(s.Text)
		}

		fullText := builder.String()
		if fullText == "" {
			continue
		}

		romanized, err := romanizeTexts([]string{fullText})
		if err != nil {
			return nil, err
		}

		romanizedFullLine := ""
		if len(romanized) > 0 {
			romanizedFullLine = romanized[0]
		}

		newWords := make([]*commonpb.LyricsLine_Syllable, len(line.Text))
		for j, s := range line.Text {
			if s == nil {
				continue
			}
			cloned := proto.Clone(s).(*commonpb.LyricsLine_Syllable)
			newWords[j] = cloned
		}

		finalLines[i].Text = newWords
		if romanizedFullLine != "" {
			finalLines[i].RomanizedText = &romanizedFullLine
		}
	}

	return finalLines, nil
}

func romanizeLineSynced(lines []*commonpb.LyricsLine) ([]*commonpb.LyricsLine, error) {
	linesToRomanize := make([]string, 0, len(lines))
	for _, line := range lines {
		if line.RomanizedText != nil && *line.RomanizedText != "" {
			linesToRomanize = append(linesToRomanize, "")
			continue
		}

		if len(line.Text) > 0 {
			joinedLine := strings.Builder{}

			for _, text := range line.Text {
				joinedLine.WriteString(text.Text)
			}

			linesToRomanize = append(linesToRomanize, joinedLine.String())
			continue
		}

		linesToRomanize = append(linesToRomanize, "")
	}

	romanizedLines, err := romanizeTexts(linesToRomanize)
	if err != nil {
		return nil, err
	}

	finalLines := make([]*commonpb.LyricsLine, len(lines))
	copy(finalLines, lines)

	for i := range finalLines {
		romanizedLine := romanizedLines[i]

		if romanizedLine != "" {
			finalLines[i].RomanizedText = &romanizedLines[i]
		}
	}

	return finalLines, nil
}

func romanizeTexts(texts []string) ([]string, error) {
	contentText := strings.Join(texts, " ")

	if isPurelyLatinScript(contentText) {
		return texts, nil
	}

	romanizedTexts := make([]string, 0)
	for _, text := range texts {
		if text == "" || isPurelyLatinScript(text) {
			romanizedTexts = append(romanizedTexts, text)
			continue
		}

		attempt, success := 0, false
		var lastError error

		retry := func(err error) {
			lastError = err
			attempt++
			logging.Logger.Warn("Error romanizing text.", zap.Int("attempt", attempt), zap.String("text", text))
			if attempt < googleConfigMaxRetries {
				time.Sleep(time.Duration(math.Pow(float64(googleConfigRetryDelayMS*(time.Millisecond*2)), float64(attempt-1))))
			}
		}

		for attempt < googleConfigMaxRetries && !success {
			request, err := http.NewRequest(http.MethodGet, googleTranslateURL, nil)
			if err != nil {
				retry(err)
				continue
			}

			response, err := http.DefaultClient.Do(request)
			if err != nil {
				retry(err)
				continue
			}

			var data [][][]any
			if err := json.NewDecoder(response.Body).Decode(&data); err != nil {
				retry(err)
				continue
			}

			// Reference (Original TypeScript):
			// const romanized = data?.[0]?.[0]?.[3] || text;
			romanized, ok := data[0][0][3].(string)
			if romanized == "" || !ok {
				romanized = text
			}

			romanizedTexts = append(romanizedTexts, romanized)
			success = true
		}

		if !success {
			logging.Logger.Error("Failed to romanize text.", zap.Int("attempt", googleConfigMaxRetries), zap.Error(lastError))
			romanizedTexts = append(romanizedTexts, text)
		}
	}

	return romanizedTexts, nil
}
