package security

import (
	"strings"

	"github.com/gofiber/fiber/v2"
)

func IsSurfaceUntrustedClientCheckPassing(ctx *fiber.Ctx) bool {
	userAgent := ctx.Get("User-Agent")

	if userAgent == "" || userAgent == "Mozilla/5.0" {
		return false
	}

	if strings.Contains(userAgent, "lavf") ||
		strings.Contains(userAgent, "ffmpeg") ||
		strings.Contains(userAgent, "curl") ||
		strings.Contains(userAgent, "wget") ||
		strings.Contains(userAgent, "python-requests") ||
		strings.Contains(userAgent, "Go-http-client") ||
		strings.Contains(userAgent, "okhttp") {
		return false
	}

	return true
}
