package lyricspipe

import (
	"math"
	"strconv"
	"strings"
)

func timeToMs(timeStr string) int {
	if timeStr == "" {
		return 0
	}

	parts := strings.Split(timeStr, ":")
	var seconds float64

	parseInt := func(s string) int {
		v, _ := strconv.Atoi(s)
		return v
	}

	parseFloat := func(s string) float64 {
		v, _ := strconv.ParseFloat(s, 64)
		return v
	}

	if len(parts) == 2 {
		seconds = float64(parseInt(parts[0]))*60 + parseFloat(parts[1])
	} else if len(parts) == 3 {
		seconds =
			float64(parseInt(parts[0]))*3600 +
				float64(parseInt(parts[1]))*60 +
				parseFloat(parts[2])
	} else {
		seconds = parseFloat(parts[0])
	}

	return int(math.Round(seconds * 1000))
}

func toMilliseconds(value any, fallback int) int {
	var num float64

	switch v := value.(type) {
	case int:
		num = float64(v)
	case int64:
		num = float64(v)
	case float64:
		num = v
	case string:
		f, err := strconv.ParseFloat(v, 64)
		if err != nil {
			return fallback
		}
		num = f
	default:
		return fallback
	}

	if math.IsNaN(num) || math.IsInf(num, 0) {
		return fallback
	}

	if num != math.Trunc(num) {
		return int(math.Round(num * 1000))
	}

	return int(math.Max(0, math.Round(num)))
}
