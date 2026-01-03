package artist_controllers

import (
	"wavelength/services/gateway/models"
	shared_db "wavelength/shared/db"

	"github.com/gofiber/fiber/v2"
)

func IsFollowingArtist(ctx *fiber.Ctx) error {
	browseId := ctx.Params("browseId")

	if browseId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Browse ID is required.")
	}

	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	var followingCount int

	row := shared_db.Database.QueryRow(`
		SELECT COUNT(*) FROM "follows"
		WHERE artist_browse_id = $1 AND follower_email = $2;
	`, browseId, authUser.Email)

	if err := row.Scan(&followingCount); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get following count from database.")
	}

	isFollowingArtist := followingCount > 0
	return models.Success(ctx, isFollowingArtist)
}
