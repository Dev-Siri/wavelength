package utils

import (
	"net/url"
	"strconv"
	"strings"
	"wavelength/models"

	"github.com/gofiber/fiber/v2"
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

func ParseRangeHeader(rangeHeader string) (*models.PlaybackRange, error) {
	var playbackRange *models.PlaybackRange = nil
	var start, end int64 = 0, -1

	if rangeHeader != "" {
		if after, ok := strings.CutPrefix(rangeHeader, "bytes="); ok {
			rangeStr := after
			parts := strings.Split(rangeStr, "-")

			if len(parts) == 2 {
				var err error

				if parts[0] != "" {
					start, err = strconv.ParseInt(parts[0], 10, 64)

					if err != nil {
						return nil, fiber.NewError(fiber.StatusRequestedRangeNotSatisfiable, "Invalid range start")
					}
				}

				if parts[1] != "" {
					end, err = strconv.ParseInt(parts[1], 10, 64)

					if err != nil {
						return nil, fiber.NewError(fiber.StatusRequestedRangeNotSatisfiable, "Invalid range end")
					}
				}

				playbackRange = &models.PlaybackRange{
					Start: start,
					End:   end,
				}
			}
		}
	}

	return playbackRange, nil
}
