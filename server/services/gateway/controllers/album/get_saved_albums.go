package album_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
)

func GetSavedAlbums(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(shared_models.AuthUser)
	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	savedAlbumsResponse, err := clients.AlbumClient.GetSavedAlbums(ctx.Context(), &albumpb.GetSavedAlbumsRequest{
		SaverEmail: authUser.Email,
	})
	if err != nil {
		logging.Logger.Error("AlbumService: 'GetSavedAlbums' errored.")
		return fiber.NewError(fiber.StatusInternalServerError, "Saved albums fetch failed.")
	}

	return shared_models.Success(ctx, savedAlbumsResponse)
}
