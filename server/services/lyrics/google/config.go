package google

import "time"

const (
	googleConfigMaxRetries   = 5
	googleConfigRetryDelayMS = time.Millisecond * 1000
	googleTranslateURL       = "https://translate.googleapis.com/translate_a/single"
)
