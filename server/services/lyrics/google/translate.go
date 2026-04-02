package google

import (
	"encoding/json"
	"math"
	"net/http"
	"strings"
	"time"
)

const batchSizeChars = 1500

func Translate(texts []string, targetLanguage string) ([]string, error) {
	nonEmptyIndices := make([]int, 0)
	textsToTranslate := make([]string, 0)

	for i, t := range texts {
		if t != "" && strings.TrimSpace(t) != "" {
			nonEmptyIndices = append(nonEmptyIndices, i)
			textsToTranslate = append(textsToTranslate, t)
		}
	}

	if len(textsToTranslate) == 0 {
		return texts, nil
	}

	translatedResults := make([]string, len(textsToTranslate))

	currentBatch := make([]string, 0)
	currentBatchIndices := make([]int, 0)
	currentBatchLength := 0

	processBatch := func(batch []string, indices []int) {
		if len(batch) == 0 {
			return
		}

		joinedText := strings.Join(batch, "\n")
		attempt, success := 0, false

		retry := func() {
			attempt++
			if attempt < googleConfigMaxRetries {
				time.Sleep(time.Duration(math.Pow(float64(googleConfigRetryDelayMS*(time.Millisecond*2)), float64(attempt-1))))
			} else {
				for i, originalIndex := range indices {
					translatedResults[originalIndex] = batch[i]
				}
			}
		}

		type googleTranslateResult [][]any

		for attempt < googleConfigMaxRetries && !success {
			request, err := http.NewRequest(http.MethodGet, googleTranslateURL, nil)
			if err != nil {
				retry()
				continue
			}

			q := request.URL.Query()
			q.Set("client", "gtx")
			q.Set("sl", "auto")
			q.Set("tl", targetLanguage)
			q.Set("dt", "t")
			q.Set("q", joinedText)
			request.URL.RawQuery = q.Encode()

			response, err := http.DefaultClient.Do(request)
			if err != nil {
				retry()
				continue
			}

			var translateResult googleTranslateResult
			if err := json.NewDecoder(response.Body).Decode(&translateResult); err != nil {
				response.Body.Close()
				retry()
				continue
			}

			response.Body.Close()

			/**
			// Data -> first element -> map each segment to its first element -> join all segments
			// Reference (Original TS code):
			const fullTranslation = data?.[0]?.map((seg: any) => seg?.[0]).join("") || "";
			*/
			fullTranslation := strings.Builder{}
			for _, item := range translateResult[0] {
				segment, ok := item.([]any)
				if !ok || len(segment) == 0 {
					continue
				}

				str, ok := segment[0].(string)
				if !ok {
					continue
				}

				fullTranslation.WriteString(str)
			}

			lines := strings.Split(fullTranslation.String(), "\n")

			for i, originalIndex := range indices {
				if i < len(lines) {
					translatedResults[originalIndex] = lines[i]
				} else {
					translatedResults[originalIndex] = batch[i]
				}
			}

			success = true
		}
	}

	for i, text := range textsToTranslate {
		if (currentBatchLength + len(text)) > batchSizeChars {
			processBatch(currentBatch, currentBatchIndices)
			currentBatch = nil
			currentBatchIndices = nil
			currentBatchLength = 0
		}

		currentBatch = append(currentBatch, text)
		currentBatchIndices = append(currentBatchIndices, i)
		currentBatchLength += len(text)
	}

	if len(currentBatch) > 0 {
		processBatch(currentBatch, currentBatchIndices)
	}

	finalArray := make([]string, len(texts))
	copy(finalArray, texts)

	for mappedIndex, realIndex := range nonEmptyIndices {
		finalArray[realIndex] = translatedResults[mappedIndex]
	}
	return finalArray, nil
}
