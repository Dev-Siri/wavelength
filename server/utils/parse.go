package utils

import (
	"net/mail"
	"net/url"
	"regexp"
	"strconv"
	"strings"
	"wavelength/models"

	"github.com/gofiber/fiber/v2"
)

// https://stackoverflow.com/a/66624104/18646049
func IsValidEmail(email string) bool {
	_, err := mail.ParseAddress(email)
	return err == nil
}

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

func ParseDuration(iso string) int {
	re := regexp.MustCompile(`PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?`)
	matches := re.FindStringSubmatch(iso)

	h, _ := strconv.Atoi(matches[1])
	m, _ := strconv.Atoi(matches[2])
	s, _ := strconv.Atoi(matches[3])

	return h*3600 + m*60 + s
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
