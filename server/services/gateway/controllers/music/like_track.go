package music_controllers

import (
	"encoding/json"
	"wavelength/services/gateway/db"
	"wavelength/services/gateway/models"
	"wavelength/services/gateway/models/schemas"
	"wavelength/services/gateway/validation"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

func LikeTrack(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)
	body := ctx.Body()
	// Versatile schema.
	var parsedBody schemas.PlaylistTrackAdditionSchema
	if err := json.Unmarshal(body, &parsedBody); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to read body: "+err.Error())
	}

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	// Check if already liked.
	var likesCount int

	row := db.Database.QueryRow(`
		SELECT COUNT(*) FROM "likes"
		WHERE email = $1 AND video_id = $2;
	`, authUser.Email, parsedBody.VideoId)

	if err := row.Scan(&likesCount); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to read like data count: "+err.Error())
	}

	if likesCount > 0 {
		// Perform unlike instead.
		_, err := db.Database.Exec(`
			DELETE FROM "likes"
			WHERE email = $1 AND video_id = $2;
		`, authUser.Email, parsedBody.VideoId)

		if err != nil {
			return fiber.NewError(fiber.StatusInternalServerError, "Failed to unlike track: "+err.Error())
		}

		ctx.Status(fiber.StatusOK)
		return ctx.JSON(models.Success("Track removed from likes."))
	}

	// Perform a like.
	likeId := uuid.NewString()

	if !validation.IsPlaylistTrackAdditionShapeValid(parsedBody) {
		return fiber.NewError(fiber.StatusBadRequest, "Liked track to add isn't in proper shape.")
	}

	_, err := db.Database.Exec(`
		INSERT INTO "likes" (
			like_id,
			email,
			title,
			thumbnail,
			is_explicit,
			duration,
			author,
			video_id,
			video_type
		) VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9 );
	`, likeId, authUser.Email, parsedBody.Title, parsedBody.Thumbnail,
		parsedBody.IsExplicit, parsedBody.Duration, parsedBody.Author,
		parsedBody.VideoId, parsedBody.VideoType)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to like track: "+err.Error())
	}

	ctx.Status(fiber.StatusOK)
	return ctx.JSON(models.Success("Track saved to likes."))
}
