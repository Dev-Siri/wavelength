package security

import (
	"errors"
	"time"

	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func ValidatePlaybackRequestDetails(ctx *fiber.Ctx, clientDetails *TokenClientDetails, authUser *shared_models.AuthUser) error {
	videoID := ctx.Params("videoId")
	if videoID == "" {
		logging.Logger.Error("Missing videoId.")
		return fiber.NewError(fiber.StatusBadRequest, "Something doesn't look right.")
	}

	if time.Now().Unix() > clientDetails.Expiration {
		logging.Logger.Warn("Token expired.", zap.Any("clientDetails", clientDetails))
		return errors.New("Something doesn't look right.")
	}

	if clientDetails.VideoID != videoID {
		logging.Logger.Warn("Video ID mismatch.",
			zap.String("expected", clientDetails.VideoID),
			zap.String("actual", videoID),
		)
		return errors.New("Something doesn't look right.")
	}

	if clientDetails.Email != authUser.Email {
		logging.Logger.Warn("Email mismatch.",
			zap.String("expected", clientDetails.Email),
			zap.String("actual", authUser.Email),
		)
		return errors.New("Something doesn't look right.")
	}

	requestIP := ctx.IP()
	if clientDetails.IP != requestIP {
		logging.Logger.Warn("Client IP mismatch.",
			zap.String("expected", clientDetails.IP),
			zap.String("actual", requestIP),
		)
		return errors.New("Something doesn't look right.")
	}

	return nil
}
