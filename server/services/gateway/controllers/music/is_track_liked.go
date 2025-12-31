package music_controllers

import (
	"wavelength/services/gateway/db"
	"wavelength/services/gateway/models"

	"github.com/gofiber/fiber/v2"
)

func IsTrackLiked(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")

	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Parameter 'videoId' is required.")
	}

	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	// Check if already liked.
	var likesCount int

	row := db.Database.QueryRow(`
		SELECT COUNT(*) FROM "likes"
		WHERE email = $1 AND video_id = $2;
	`, authUser.Email, videoId)

	if err := row.Scan(&likesCount); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to read like data count: "+err.Error())
	}

	isLiked := likesCount > 0

	return ctx.JSON(models.Success(isLiked))
}
