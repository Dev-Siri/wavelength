package google

import "unicode"

func isPurelyLatinScript(text string) bool {
	for _, r := range text {
		if !unicode.Is(unicode.Latin, r) {
			return false
		}
	}
	return true
}
