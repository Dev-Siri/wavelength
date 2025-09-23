package utils

import (
	"net/url"
	"strconv"
	"strings"
)

func IsValidUrl(testUrl string) bool {
	_, err := url.ParseRequestURI(testUrl)
	return err == nil
}

func ParseDurationToSeconds(duration string) int {
	durationParts := strings.Split(duration, ":")

	if len(durationParts) < 2 {
		return 0
	}

	minutesStr, secondsStr := durationParts[0], durationParts[1]

	minutes, err := strconv.Atoi(minutesStr)

	if err != nil {
		return 0
	}

	seconds, err := strconv.Atoi(secondsStr)

	if err != nil {
		return 0
	}

	minutesInSeconds := minutes * 60

	return minutesInSeconds + seconds
}
