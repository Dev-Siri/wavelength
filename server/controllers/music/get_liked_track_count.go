package music_controllers

import (
	"wavelength/db"
	"wavelength/models"

	"github.com/gofiber/fiber/v2"
)

func GetLikedTrackCount(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	var likeCount int

	row := db.Database.QueryRow(`
		SELECT COUNT(*) FROM "likes"
		WHERE email = $1;
	`, authUser.Email)

	if err := row.Scan(&likeCount); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to read like count: "+err.Error())
	}

	return ctx.JSON(models.Success(likeCount))
}
