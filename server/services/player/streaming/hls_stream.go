package streaming

import (
	"bufio"
	"net/http"
	"strings"

	"github.com/Dev-Siri/wavelength/server/services/player/security"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func ConstructHlsPlaylistResponse(ctx *fiber.Ctx, clientDetails *security.TokenClientDetails, m3u8PlaylistURL string) error {
	ctx.Type("application/vnd.apple.mpegurl")
	response, err := http.Get(m3u8PlaylistURL)
	if err != nil {
		logging.Logger.Error("Playlist fetch failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlist fetch failed.")
	}

	defer response.Body.Close()

	scanner := bufio.NewScanner(response.Body)

	for scanner.Scan() {
		line := scanner.Text()

		if line == "" || strings.HasPrefix(line, "#") {
			if strings.Contains(line, "init.mp4") {
				signedURL, err := PickAndGenerateStreamURL("init.mp4", clientDetails)
				if err != nil {
					logging.Logger.Error("Signed URL generation failed", zap.Error(err))
					return fiber.NewError(fiber.StatusInternalServerError, "Playlist fetch failed.")
				}

				ctx.WriteString(strings.Replace(line, "init.mp4", signedURL, 1) + "\n")
				continue
			}

			ctx.WriteString(line + "\n")
			continue
		}

		signedURL, err := PickAndGenerateStreamURL(line, clientDetails)
		if err != nil {
			logging.Logger.Error("Signed URL generation failed", zap.Error(err))
			return fiber.NewError(fiber.StatusInternalServerError, "Playlist fetch failed.")
		}

		ctx.WriteString(signedURL + "\n")
	}

	return nil
}
