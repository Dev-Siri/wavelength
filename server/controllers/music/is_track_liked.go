package music_controllers

import (
	"wavelength/db"
	"wavelength/models"

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

	row, err := db.Database.Query(`
		SELECT COUNT(*) FROM "likes"
		WHERE email = $1 AND video_id = $2;
	`, authUser.Email, videoId)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to read like count from database: "+err.Error())
	}

	row.Next()
	if err := row.Scan(&likesCount); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to read like data count: "+err.Error())
	}

	defer row.Close()

	isLiked := likesCount > 0

	return ctx.JSON(models.Success(isLiked))
}
