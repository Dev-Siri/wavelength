package music_controllers

import (
	"wavelength/services/gateway/db"
	"wavelength/services/gateway/models"

	"github.com/gofiber/fiber/v2"
)

func GetLikedTracks(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	rows, err := db.Database.Query(`
		SELECT
			like_id,
			email,
			title,
			thumbnail,
			is_explicit,
			author,
			duration,
			video_id,
			video_type
		FROM "likes"
		WHERE email = $1;
	`, authUser.Email)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get liked tracks from database: "+err.Error())
	}

	defer rows.Close()

	tracks := make([]models.LikedTrack, 0)

	for rows.Next() {
		var track models.LikedTrack

		if err := rows.Scan(
			&track.LikeId,
			&track.Email,
			&track.Title,
			&track.Thumbnail,
			&track.IsExplicit,
			&track.Author,
			&track.Duration,
			&track.VideoId,
			&track.VideoType,
		); err != nil {
			return fiber.NewError(fiber.StatusInternalServerError, "Failed to get your liked tracks: "+err.Error())
		}

		tracks = append(tracks, track)
	}

	return ctx.JSON(models.Success(tracks))
}
