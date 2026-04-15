package player_controllers

import (
	"errors"
	"strconv"
	"strings"
	"time"

	"github.com/Dev-Siri/wavelength/server/services/player/models"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

type recordStreamRequest struct {
	Type      string                `json:"type"`
	Timestamp uint64                `json:"timestamp"`
	Track     models.QueueableMusic `json:"track"`
}

// This handler should execute regardless of client disconnects.
func RecordStream(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(shared_models.AuthUser)
	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	var streamRecord recordStreamRequest
	if err := ctx.BodyParser(&streamRecord); err != nil {
		logging.Logger.Error("Body parse failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Body parse failed.")
	}

	exists, err := isExistingStreamRecord(streamRecord.Track.VideoID)
	if err != nil {
		logging.Logger.Error("Existing stream source check failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Existing stream source check failed.")
	}

	if !exists {
		artistText := strings.Builder{}
		for _, artist := range streamRecord.Track.Artists {
			artistText.WriteString(artist.Title)
			artistText.WriteString("|")
		}

		var duration int
		switch v := streamRecord.Track.Duration.(type) {
		case string:
			duration, err = strconv.Atoi(v)
			if err != nil {
				logging.Logger.Error("Duration parse failed.", zap.Error(err))
				return fiber.NewError(fiber.StatusInternalServerError, "Duration parse failed.")
			}
		case float64:
			duration = int(v)
		default:
			logging.Logger.Error("Invalid duration type.", zap.Any("type", v))
			return fiber.NewError(fiber.StatusBadRequest, "Invalid duration type.")
		}

		videoType, err := parseVideoType(streamRecord.Track.VideoType)
		if err != nil {
			logging.Logger.Error("Video type parse failed.", zap.Error(err))
			return fiber.NewError(fiber.StatusInternalServerError, "Video type parse failed.")
		}

		if _, err := shared_db.AnalyticsDatabase.Exec(`
			INSERT INTO "played_tracks" (
				video_id,
				title,
				artist,
				album,
				duration,
				video_type
			) VALUES ( $1, $2, $3, $4, $5, $6 )
			ON CONFLICT DO NOTHING;
		`, streamRecord.Track.VideoID, streamRecord.Track.Title, artistText.String(), streamRecord.Track.Album.Title, duration, videoType); err != nil {
			logging.Logger.Error("Stream record insertion failed.", zap.Error(err))
			return fiber.NewError(fiber.StatusInternalServerError, "Stream record insertion failed.")
		}
	}

	eventID := uuid.NewString()
	timestamp := time.UnixMilli(int64(streamRecord.Timestamp))
	eventType, err := parseTypeToEventType(streamRecord.Type)
	if err != nil {
		logging.Logger.Error("Event type parsing failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusBadRequest, "Invalid event type.")
	}

	_, err = shared_db.AnalyticsDatabase.Exec(`
		INSERT INTO "track_events" (
			event_id,
			event_timestamp,
			video_id,
			email,
			event_type
		) VALUES ( $1, $2, $3, $4, $5 );
	`, eventID, timestamp, streamRecord.Track.VideoID, authUser.Email, eventType)
	if err != nil {
		logging.Logger.Error("Track events record failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Track events record failed.")
	}

	return ctx.SendStatus(fiber.StatusNoContent)
}

func isExistingStreamRecord(videoID string) (bool, error) {
	row := shared_db.AnalyticsDatabase.QueryRow(`
		SELECT EXISTS (
			SELECT 1 FROM "played_tracks" WHERE video_id = $1
		);
	`, videoID)

	var exists bool
	if err := row.Scan(&exists); err != nil {
		return false, err
	}

	return exists, nil
}

func parseTypeToEventType(eventType string) (string, error) {
	switch eventType {
	case "playStart":
		return "play_start", nil
	case "play30s":
		return "play_30s", nil
	case "skipFast":
		return "skip_fast", nil
	default:
		return "", errors.New("Invalid event type.")
	}
}

func parseVideoType(videoType string) (string, error) {
	switch videoType {
	case "VIDEO_TYPE_TRACK":
		return "track", nil
	case "VIDEO_TYPE_UVIDEO":
		return "uvideo", nil
	default:
		return "", errors.New("Invalid video type.")
	}
}
