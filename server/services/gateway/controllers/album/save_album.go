package album_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
)

func SaveAlbum(ctx *fiber.Ctx) error {
	albumID := ctx.Params("albumId")
	if albumID == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Album ID is required.")
	}

	authUser, ok := ctx.Locals("authUser").(shared_models.AuthUser)
	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	albumSaveResponse, err := clients.AlbumClient.SaveAlbum(ctx.Context(), &albumpb.SaveAlbumRequest{
		AlbumId:    albumID,
		SaverEmail: authUser.Email,
	})
	if err != nil {
		logging.Logger.Error("AlbumService: 'SaveAlbum' errored.")
		return fiber.NewError(fiber.StatusInternalServerError, "Album save failed.")
	}

	return shared_models.Success(ctx, albumSaveResponse)
}
