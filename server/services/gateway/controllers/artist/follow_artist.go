package artist_controllers

import (
	"encoding/json"
	"wavelength/services/gateway/models"
	"wavelength/services/gateway/models/schemas"
	"wavelength/services/gateway/validation"
	shared_db "wavelength/shared/db"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

func FollowArtist(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	body := ctx.Body()
	var parsedBody schemas.ArtistFollowSchmea

	if err := json.Unmarshal(body, &parsedBody); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to parse body: "+err.Error())
	}

	if !validation.IsFollowArtistShapeValid(parsedBody) {
		return fiber.NewError(fiber.StatusInternalServerError, "Body is not in valid shape.")
	}

	var followCount int

	row := shared_db.Database.QueryRow(`
		SELECT COUNT(*) FROM "follows"
		WHERE follower_email = $1 AND artist_browse_id = $2; 
	`, authUser.Email, parsedBody.BrowseId)

	if err := row.Scan(&followCount); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to read follow count from database.")
	}

	if followCount > 0 {
		_, err := shared_db.Database.Exec(`
			DELETE FROM "follows"
			WHERE follower_email = $1 AND artist_browse_id = $2;
		`, authUser.Email, parsedBody.BrowseId)

		if err != nil {
			return fiber.NewError(fiber.StatusInternalServerError, "Failed to unfollow artist: "+err.Error())
		}

		return ctx.JSON(models.Success("Successfully unfollowed artist."))
	}

	_, err := shared_db.Database.Exec(`
			INSERT INTO "follows" (
				follower_email,
				follow_id,
				artist_name,
				artist_thumbnail,
				artist_browse_id
			)
		`, authUser.Email, uuid.NewString(), parsedBody.Name, parsedBody.Thumbnail, parsedBody.BrowseId)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to follow artist: "+err.Error())
	}

	return ctx.JSON(models.Success("Successfully followed artist."))
}
