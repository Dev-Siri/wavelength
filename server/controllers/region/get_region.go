package region_controllers

import (
	"io"
	"net/http"
	"time"
	"wavelength/constants"
	"wavelength/logging"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetRegion(ctx *fiber.Ctx) error {
	region := ctx.Cookies(constants.RegionCookieKey)

	if region == "" {
		clientAddress := ctx.IP()
		infiniteTime := time.Date(9999, 0, 1, 0, 0, 0, 0, time.UTC)

		response, err := http.Get("https://ipapi.co/" + clientAddress + "/country")

		if err != nil {
			go logging.Logger.Error("Failed to get region.", zap.Error(err))
			ctx.Cookie(&fiber.Cookie{
				Name:     constants.RegionCookieKey,
				Value:    constants.DefaultRegion,
				HTTPOnly: false,
				Secure:   false,
				Expires:  infiniteTime,
			})
			region = constants.DefaultRegion
		}

		countryCode, err := io.ReadAll(response.Body)

		if err != nil {
			go logging.Logger.Error("Failed to decipher region.", zap.Error(err))
			ctx.Cookie(&fiber.Cookie{
				Name:     constants.RegionCookieKey,
				Value:    constants.DefaultRegion,
				HTTPOnly: false,
				Secure:   false,
				Expires:  infiniteTime,
			})
			region = constants.DefaultRegion
		}

		region = string(countryCode)
		ctx.Cookie(&fiber.Cookie{
			Name:     constants.RegionCookieKey,
			Value:    region,
			HTTPOnly: false,
			Secure:   false,
			Expires:  infiniteTime,
		})
	}

	ctx.JSON(
		&responses.Success[string]{
			Success: true,
			Data:    region,
		},
	)

	return nil
}
