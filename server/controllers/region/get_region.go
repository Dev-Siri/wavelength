package region_controllers

import (
	"net/netip"
	"time"
	"wavelength/constants"
	"wavelength/db"
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

		netAddress, err := netip.ParseAddr(clientAddress)

		if err != nil {
			go logging.Logger.Error("Failed to get region.", zap.Error(err))
			ctx.Cookie(&fiber.Cookie{
				Name:     constants.RegionCookieKey,
				Value:    constants.DefaultRegion,
				HTTPOnly: false,
				Secure:   false,
				Expires:  infiniteTime,
			})
			return ctx.JSON(
				&responses.Success[string]{
					Success: true,
					Data:    constants.DefaultRegion,
				},
			)
		}

		geoIpLookup, err := db.GeoIpDb.Country(netAddress)

		if err != nil {
			go logging.Logger.Error("Failed to get region.", zap.Error(err))
			ctx.Cookie(&fiber.Cookie{
				Name:     constants.RegionCookieKey,
				Value:    constants.DefaultRegion,
				HTTPOnly: false,
				Secure:   false,
				Expires:  infiniteTime,
			})
			return ctx.JSON(
				&responses.Success[string]{
					Success: true,
					Data:    constants.DefaultRegion,
				},
			)
		}

		region = geoIpLookup.Country.ISOCode

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
