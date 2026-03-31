package streaming

import (
	"bufio"
	"net/http"
	"strings"

	"github.com/Dev-Siri/wavelength/server/services/player/security"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

const (
	AutoStandardPlaylistName = "standard.m3u8"
	AutoTopPlaylistName      = "hifitop.m3u8"
	AutoBasePlaylistName     = "hifibase.m3u8"
)

func ConstructAutoMasterPlaylistResponse(
	ctx *fiber.Ctx,
	authToken string,
) error {
	ctx.Type("application/vnd.apple.mpegurl")

	ctx.WriteString("#EXTM3U\n")
	ctx.WriteString("#EXT-X-VERSION:3\n\n")
	ctx.WriteString("#EXT-X-INDEPENDENT-SEGMENTS\n")

	ctx.WriteString(`#EXT-X-STREAM-INF:BANDWIDTH=128000` + "\n")
	ctx.WriteString(AutoStandardPlaylistName + "?authToken=" + authToken + "\n")

	ctx.WriteString(`#EXT-X-STREAM-INF:BANDWIDTH=256000,CODECS="mp4a.40.2"` + "\n")
	ctx.WriteString(AutoBasePlaylistName + "?authToken=" + authToken + "\n")

	ctx.WriteString(`#EXT-X-STREAM-INF:BANDWIDTH=320000,CODECS="mp4a.40.2"` + "\n")
	ctx.WriteString(AutoTopPlaylistName + "?authToken=" + authToken + "\n")

	return nil
}

func ConstructHifiAutoHlsPlaylistResponse(ctx *fiber.Ctx, clientDetails *security.TokenClientDetails, m3u8PlaylistURL, streamPartName string) error {
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
				var signedInitMp4URL string
				var err error

				switch streamPartName {
				case AutoTopPlaylistName:
					signedInitMp4URL, err = shared_db.GenerateTopHifiURL(clientDetails.ISRC, "init.mp4")
				case AutoBasePlaylistName:
					signedInitMp4URL, err = shared_db.GenerateBaseHifiURL(clientDetails.ISRC, "init.mp4")
				default:
					signedInitMp4URL, err = shared_db.GenerateAdaptiveURL(clientDetails.VideoID, "init.mp4")
				}

				if err != nil {
					logging.Logger.Error("Signed URL generation failed", zap.Error(err))
					return fiber.NewError(fiber.StatusInternalServerError, "Playlist fetch failed.")
				}

				ctx.WriteString(strings.Replace(line, "init.mp4", signedInitMp4URL, 1) + "\n")
				continue
			}

			ctx.WriteString(line + "\n")
			continue
		}

		if streamPartName == AutoStandardPlaylistName {
			signedURL, err := shared_db.GenerateAdaptiveURL(clientDetails.VideoID, line)
			if err != nil {
				logging.Logger.Error("Signed URL generation failed for Standard. (Auto) Aborting entire stream.")
				return fiber.NewError(fiber.StatusInternalServerError, "Playlist fetch failed.")
			}
			ctx.WriteString(signedURL + "\n")
		}

		if streamPartName == AutoBasePlaylistName {
			signedURL, err := shared_db.GenerateBaseHifiURL(clientDetails.ISRC, line)
			if err != nil {
				logging.Logger.Error("Signed URL generation failed for Hifi-Base. (Auto) Aborting entire stream.")
				return fiber.NewError(fiber.StatusInternalServerError, "Playlist fetch failed.")
			}
			ctx.WriteString(signedURL + "\n")
		}

		if streamPartName == AutoTopPlaylistName {
			signedURL, err := shared_db.GenerateTopHifiURL(clientDetails.ISRC, line)
			if err != nil {
				logging.Logger.Error("Signed URL generation failed for Hifi-Top. (Auto) Aborting entire stream.")
				return fiber.NewError(fiber.StatusInternalServerError, "Playlist fetch failed.")
			}
			ctx.WriteString(signedURL + "\n")
		}

		ctx.WriteString(line + "\n")
	}

	return nil
}

func hifiAutoStreamingHandler(streamPartName, isrc, videoID string) (string, error) {
	if streamPartName == AutoStandardPlaylistName {
		logging.Logger.Debug("Master playlist requested Adaptive (Opus/AAC ~128kbps)")
		return shared_db.GenerateAdaptiveURL(videoID, "index.m3u8")
	}

	if streamPartName == AutoBasePlaylistName {
		logging.Logger.Debug("Master playlist requested High Quality (AAC 256kbps)")
		return shared_db.GenerateBaseHifiURL(isrc, "index.m3u8")
	}

	if streamPartName == AutoTopPlaylistName {
		logging.Logger.Debug("Master playlist requested Hi-Fi (AAC 320kbps)")
		return shared_db.GenerateTopHifiURL(isrc, "index.m3u8")
	}

	return "", nil
}
