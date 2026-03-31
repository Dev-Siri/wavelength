package google

import "regexp"

var latinScriptRegex = regexp.MustCompile(`^[\u0000-\u007F\u0080-\u00FF\u0100-\u017F\u0180-\u024F]*$`)

func isPurelyLatinScript(text string) bool {
	return latinScriptRegex.MatchString(text)
}
