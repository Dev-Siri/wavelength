package artist_controllers

import (
	"wavelength/services/gateway/models"
	shared_db "wavelength/shared/db"

	"github.com/gofiber/fiber/v2"
)

func GetFollowedArtists(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	rows, err := shared_db.Database.Query(`
		SELECT
			follow_id,
			follower_email,
			artist_name,
			artist_thumbnail,
			artist_browse_id
		FROM "follows"
		WHERE email = $1;
	`, authUser.Email)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get followed artists from database: "+err.Error())
	}

	followedArtists := make([]models.FollowedArtist, 0)

	for rows.Next() {
		var followedArtist models.FollowedArtist

		if err := rows.Scan(
			&followedArtist.FollowId,
			&followedArtist.FollowerEmail,
			&followedArtist.ArtistName,
			&followedArtist.ArtistThumbnail,
			&followedArtist.ArtistBrowseId,
		); err != nil {
			return fiber.NewError(fiber.StatusInternalServerError, "Failed to parse artist: "+err.Error())
		}

		followedArtists = append(followedArtists, followedArtist)
	}

	return ctx.JSON(models.Success(followedArtists))
}
