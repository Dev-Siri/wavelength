package stream_controllers

import (
	"context"
	"database/sql"
	"strings"

	"github.com/Dev-Siri/wavelength/server/services/player/models"
	"github.com/Dev-Siri/wavelength/server/services/player/security"
	"github.com/Dev-Siri/wavelength/server/services/player/types"
	shared_type_constants "github.com/Dev-Siri/wavelength/server/shared/constants/types"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/Dev-Siri/wavelength/server/shared/tidal"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

var goEnv = shared_type_constants.GetGoEnv()
var host = getPlayerHost()

func GetStreamSource(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(shared_models.AuthUser)
	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	authorization := ctx.Get("Authorization")
	if authorization == "" {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	parts := strings.SplitN(authorization, " ", 2)

	if len(parts) != 2 || parts[0] != "Bearer" {
		return fiber.NewError(fiber.StatusUnauthorized, "Invalid Authorization header.")
	}

	tokenStr := parts[1]

	videoID := ctx.Params("videoId")
	if videoID == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	preferredQualityQuery := ctx.Query("preferredQuality")
	preferredQuality := types.NewPreferredQualityOrDefault(preferredQualityQuery)

	headers := ctx.GetReqHeaders()
	if !security.IsRequestWithBasicTrustHeaders(headers) {
		logging.Logger.Error("Basic trust headers not satisfied", zap.Any("headers", headers))
		return fiber.NewError(fiber.StatusUnauthorized, "Something doesn't look right.")
	}

	streamMetadata, err := fetchStreamMetadata(videoID, preferredQuality)
	if err != nil {
		logging.Logger.Error("Stream metadata fetch failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Stream metadata fetch failed.")
	}

	var isrc string

	if preferredQuality != types.PreferredQualityStandard && streamMetadata.IsHifiAvailable {
		fetchedISRC, err := fetchStreamISRC(ctx.Context(), videoID)
		if err != nil {
			logging.Logger.Error("Stream ISRC fetch failed.", zap.Error(err))
			return fiber.NewError(fiber.StatusInternalServerError, "Stream ISRC fetch failed.")
		}

		isrc = fetchedISRC
	}

	token, err := security.GenerateRedisToken(
		ctx.Context(),
		ctx.IP(),
		videoID,
		isrc,
		authUser.Email,
		preferredQuality,
		streamMetadata.IsHifiAvailable,
		streamMetadata.IsLosslessAvailable,
	)
	if err != nil {
		logging.Logger.Error("Stream token generation failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Stream token generation failed.")
	}

	return shared_models.Success(ctx, models.StreamSourceResponse{
		Metadata: *streamMetadata,
		Source:   getStreamSource(videoID, token, tokenStr, streamMetadata.IsHifiAvailable, preferredQuality),
	})
}

func getPlayerHost() string {
	if goEnv == shared_type_constants.GoEnvDevelopment {
		return "http://localhost:8000"
	} else {
		return "https://player-owbikridwq-el.a.run.app"
	}
}

func getStreamSource(videoID, token, authToken string, isHifiAvailable bool, preferredQuality types.PreferredQuality) string {
	var file string
	if preferredQuality == types.PreferredQualityAuto && isHifiAvailable {
		file = "master.m3u8"
	} else {
		file = "index.m3u8"
	}

	return host + "/streams/playback/" + token + "/" + videoID + "/" + file + "?authToken=" + authToken
}

func fetchStreamMetadata(videoID string, preferredQuality types.PreferredQuality) (*models.StreamMetadata, error) {
	var metadata models.StreamMetadata
	var losslessAvailable sql.NullString

	row := shared_db.StreamDatabase.QueryRow(`
		SELECT
			stream_id,
			bitrate,
			codec,
			container,
			duration_seconds,
			is_hifi_available,
			is_lossless_available
		FROM "stream_metadata"
		WHERE video_id = $1;
	`, videoID)

	if err := row.Scan(
		&metadata.StreamID,
		&metadata.Bitrate,
		&metadata.Codec,
		&metadata.Container,
		&metadata.DurationSeconds,
		&metadata.IsHifiAvailable,
		&losslessAvailable,
	); err != nil {
		return nil, err
	}

	if losslessAvailable.Valid {
		metadata.IsLosslessAvailable = (*types.LosslessBitType)(&losslessAvailable.String)
	}

	if metadata.IsHifiAvailable && preferredQuality != types.PreferredQualityStandard {
		metadata.Codec = "aac"
		metadata.Container = "m4a"

		switch preferredQuality {
		case types.PreferredQualityLossless:
			if losslessAvailable.Valid {
				metadata.Codec = "flac"
				metadata.Container = "flac"
				bitType := types.LosslessBitType(losslessAvailable.String)
				switch bitType {
				case types.LosslessBitType24Bit:
					metadata.Bitrate = 1_520_000 // 1520kbps
				case types.LosslessBitType16Bit:
					metadata.Bitrate = 1_411_000 // 1411kbps
				}
			} else {
				metadata.Bitrate = 320_000 // 320kbps
			}
		case types.PreferredQualityHifiTop:
			metadata.Bitrate = 320_000 // 320kbps
		default:
			metadata.Bitrate = 256_000 // 256kbps
		}
	}

	return &metadata, nil
}

func fetchStreamISRC(ctx context.Context, videoID string) (string, error) {
	universalIDs, err := tidal.Hifi.FetchUniversalIDs(ctx, videoID)
	if err != nil {
		return "", err
	}

	return universalIDs.ISRC, nil
}
