package lyricspipe

import (
	"regexp"
	"strings"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/PuerkitoBio/goquery"
	"golang.org/x/net/html"
)

var whitespaceRegex = regexp.MustCompile(`\s+`)

func parseTTML(ttml string) ([]*commonpb.LyricsLine, error) {
	doc, err := goquery.NewDocumentFromReader(strings.NewReader(ttml))
	if err != nil {
		return nil, err
	}

	translations := make(map[string]string)
	transliterations := make(map[string]string)
	agentMap := make(map[string]string)

	doc.Find("ttm:agent").Each(func(i int, s *goquery.Selection) {
		id, idExists := s.Attr("xml:id")
		agentType, agentExists := s.Attr("type")

		if idExists && agentExists {
			agentMap[id] = agentType
		}
	})

	doc.Find("translation").Each(func(i int, s *goquery.Selection) {
		s.Find("text").Each(func(i int, t *goquery.Selection) {
			key, exists := t.Attr("for")
			textContent := t.Text()
			if exists && textContent != "" {
				translations[key] = textContent
			}
		})
	})

	doc.Find("transliteration").Each(func(i int, s *goquery.Selection) {
		s.Find("text").Each(func(i int, t *goquery.Selection) {
			key, exists := t.Attr("for")
			textContent := t.Text()
			if exists && textContent != "" {
				transliterations[key] = whitespaceRegex.ReplaceAllString(strings.TrimSpace(textContent), " ")
			}
		})
	})

	lines := make([]*commonpb.LyricsLine, 0)
	pNodes := doc.Find("p")

	lineSingers := []string{}
	pNodes.Each(func(i int, s *goquery.Selection) {
		agent, _ := s.Attr("ttm:agent")
		lineSingers = append(lineSingers, agent)
	})

	alignments := calculateLineAlignments(lineSingers, agentMap)

	pNodes.Each(func(i int, p *goquery.Selection) {
		key, _ := p.Attr("itunes:key")

		begin, _ := p.Attr("begin")
		beginMs := timeToMs(begin)

		end, _ := p.Attr("end")
		endMs := timeToMs(end)

		var songPart *string
		parentNode := p.Parent()

		if parentNode != nil && goquery.NodeName(parentNode) == "div" {
			itunesSongPart, exists := parentNode.Attr("itunes:songpart")
			if exists {
				songPart = &itunesSongPart
			}
		}

		mainSyllables := make([]*commonpb.LyricsLine_Syllable, 0)
		bgSyllables := make([]*commonpb.LyricsLine_Syllable, 0)

		spans := p.Find("span")
		if spans.Length() > 0 {
			spans.Each(func(i int, span *goquery.Selection) {
				ttmRole, _ := span.Attr("ttm:role")
				if ttmRole == "x-bg" {
					bgInnerSpans := span.Find("span")
					bgInnerSpans.Each(func(i int, bgSpan *goquery.Selection) {
						bgText := bgSpan.Text()
						node := bgSpan.Get(0)

						if node != nil && node.NextSibling != nil &&
							node.NextSibling.Type == html.TextNode {
							nextText := node.NextSibling.Data
							if strings.HasPrefix(nextText, " ") && !strings.HasSuffix(bgText, " ") {
								bgText += " "
							}
						}

						begin, _ := bgSpan.Attr("begin")
						end, _ := bgSpan.Attr("end")

						bgSyllables = append(bgSyllables, &commonpb.LyricsLine_Syllable{
							Text:      bgText,
							Timestamp: uint64(timeToMs(begin)),
							Endtime:   uint64(timeToMs(end)),
							Part:      false,
						})
					})
					return
				}

				parentNode := span.Parent()
				ttmRole, _ = parentNode.Attr("ttm:role")

				if parentNode != nil && ttmRole == "x-bg" {
					return
				}

				text := span.Text()
				nextNode := span.Get(0).NextSibling
				if nextNode != nil && nextNode.Type == html.TextNode &&
					whitespaceRegex.MatchString(nextNode.Data) && !strings.HasSuffix(text, " ") {
					text += " "
				}

				begin, _ := span.Attr("begin")
				end, _ := span.Attr("end")

				mainSyllables = append(mainSyllables, &commonpb.LyricsLine_Syllable{
					Text:      text,
					Timestamp: uint64(timeToMs(begin)),
					Endtime:   uint64(timeToMs(end)),
					Part:      false,
				})
			})
		} else {
			lineSynced := true
			mainSyllables = append(mainSyllables, &commonpb.LyricsLine_Syllable{
				Text:       strings.TrimSpace(p.Text()),
				Timestamp:  uint64(beginMs),
				Endtime:    uint64(endMs),
				Part:       false,
				LineSynced: &lineSynced,
			})
		}

		alignment := alignments[i]
		isWordSynced := spans.Length() > 0

		line := &commonpb.LyricsLine{
			Text:           mainSyllables,
			Background:     len(bgSyllables) > 0,
			BackgroundText: bgSyllables,
			Timestamp:      uint64(beginMs),
			Endtime:        uint64(endMs),
			IsWordSynced:   &isWordSynced,
			Alignment:      alignment,
			SongPart:       songPart,
			OppositeTurn:   alignment != nil && *alignment == commonpb.LyricsLine_ALIGNMENT_DIRECTION_END,
		}

		if key != "" {
			translation := translations[key]
			romanization := transliterations[key]

			line.Translation = &translation
			line.RomanizedText = &romanization
		}

		lines = append(lines, line)
	})

	return lines, nil
}
