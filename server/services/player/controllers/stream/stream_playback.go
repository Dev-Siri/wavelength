package stream_controllers

import (
	"strings"

	"github.com/Dev-Siri/wavelength/server/services/player/security"
	"github.com/Dev-Siri/wavelength/server/services/player/streaming"
	"github.com/Dev-Siri/wavelength/server/services/player/types"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/Dev-Siri/wavelength/server/shared/middleware"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func StreamPlayback(ctx *fiber.Ctx) error {
	authToken := ctx.Query("authToken")
	authUser, err := middleware.ParseAuthUser(authToken)
	if err != nil {
		logging.Logger.Error("Auth token invalid.", zap.Error(err))
		return err
	}

	token := ctx.Params("token")
	if token == "" {
		logging.Logger.Error("Missing token.")
		return fiber.NewError(fiber.StatusUnauthorized, "Something doesn't look right.")
	}

	streamPartName := ctx.Params("part")
	if !security.IsRequestObjectResourceNameValid(streamPartName) {
		logging.Logger.Error("Access of unexpected resource.")
		return fiber.NewError(fiber.StatusBadRequest, "Something doesn't look right.")
	}

	if err := ctx.Context().Err(); err != nil {
		return err
	}

	clientDetails, err := security.FetchIPFromRedisToken(ctx.Context(), token)
	if err != nil {
		logging.Logger.Error("Client-check failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Something doesn't look right.")
	}

	if err := security.ValidatePlaybackRequestDetails(ctx, clientDetails, &authUser); err != nil {
		return fiber.NewError(fiber.StatusUnauthorized, "Something doesn't look right.")
	}

	if clientDetails.PreferredQuality == types.PreferredQualityAuto &&
		streamPartName == "master.m3u8" &&
		clientDetails.IsHifi {
		if err := ctx.Context().Err(); err != nil {
			return err
		}

		return streaming.ConstructAutoMasterPlaylistResponse(ctx, authToken)
	}

	if err := ctx.Context().Err(); err != nil {
		return err
	}
	signedURL, err := streaming.PickAndGenerateStreamURL(ctx, streamPartName, clientDetails)
	if err != nil {
		logging.Logger.Error("Stream part fetch failed.", zap.Error(err),
			zap.String("streamPartName", streamPartName), zap.String("isrc", clientDetails.ISRC))
		return fiber.NewError(fiber.StatusInternalServerError, "Stream part fetch failed.")
	}

	if strings.HasSuffix(streamPartName, ".m3u8") {
		if streamPartName == streaming.AutoTopPlaylistName ||
			streamPartName == streaming.AutoBasePlaylistName {
			if err := ctx.Context().Err(); err != nil {
				return err
			}

			return streaming.ConstructHifiAutoHlsPlaylistResponse(ctx, clientDetails, signedURL, streamPartName)
		}

		if err := ctx.Context().Err(); err != nil {
			return err
		}
		return streaming.ConstructHlsPlaylistResponse(ctx, clientDetails, signedURL)
	}

	return shared_models.Error(ctx.Status(fiber.StatusNotFound), "Requested stream not found.")
}
