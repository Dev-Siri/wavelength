package security

import (
	"time"

	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
	"github.com/slipros/devicedetector"
	"go.uber.org/zap"
)

var dd *devicedetector.DeviceDetector

func init() {
	deviceDetector, err := devicedetector.NewDeviceDetector()
	if err != nil {
		logging.Logger.Fatal("Device detector initialization failed.", zap.Error(err))
	}

	dd = deviceDetector
}

func ValidatePlaybackRequestDetails(ctx *fiber.Ctx, clientDetails *TokenClientDetails, authUser *shared_models.AuthUser) error {
	select {
	case <-ctx.Context().Done():
		return ctx.Context().Err()
	default:
	}

	videoID := ctx.Params("videoId")
	if videoID == "" {
		logging.Logger.Error("Missing videoId.")
		return fiber.NewError(fiber.StatusBadRequest, "Access denied.")
	}

	if time.Now().Unix() > clientDetails.Expiration {
		logging.Logger.Warn("Token expired.", zap.Any("clientDetails", clientDetails))
		return fiber.NewError(fiber.StatusBadRequest, "Access denied.")
	}

	if clientDetails.VideoID != videoID {
		logging.Logger.Warn("Video ID mismatch.",
			zap.String("expected", clientDetails.VideoID),
			zap.String("actual", videoID),
		)
		return fiber.NewError(fiber.StatusBadRequest, "Access denied.")
	}

	if clientDetails.Email != authUser.Email {
		logging.Logger.Warn("Email mismatch.",
			zap.String("expected", clientDetails.Email),
			zap.String("actual", authUser.Email),
		)
		return fiber.NewError(fiber.StatusBadRequest, "Access denied.")
	}

	if clientDetails.ClientType != "TV_CAST" {
		requestIP := ctx.IP()
		if clientDetails.IP != requestIP {
			logging.Logger.Warn("Client IP mismatch.",
				zap.String("expected", clientDetails.IP),
				zap.String("actual", requestIP),
			)
			return fiber.NewError(fiber.StatusBadRequest, "Access denied.")
		}
	} else {
		userAgent := ctx.Get(fiber.HeaderUserAgent)
		device := dd.Parse(userAgent)

		if device.Type != "tv" {
			logging.Logger.Warn("Client Type mismatch.",
				zap.String("expected", "tv"),
				zap.String("actual", device.Type),
			)
			return fiber.NewError(fiber.StatusBadRequest, "Access denied.")
		}
	}

	return nil
}
