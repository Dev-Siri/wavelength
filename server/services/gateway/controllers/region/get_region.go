package region_controllers

import (
	"net/netip"
	"time"
	"wavelength/services/gateway/constants"
	"wavelength/services/gateway/db"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func createDefaultResponse(ctx *fiber.Ctx, err error) error {
	infiniteTime := time.Date(9999, 0, 1, 0, 0, 0, 0, time.UTC)

	go logging.Logger.Error("Failed to get region.", zap.Error(err))

	ctx.Cookie(&fiber.Cookie{
		Name:     constants.RegionCookieKey,
		Value:    constants.DefaultRegion,
		HTTPOnly: false,
		Secure:   false,
		Expires:  infiniteTime,
	})

	return models.Success(ctx, constants.DefaultRegion)
}

func GetRegion(ctx *fiber.Ctx) error {
	region := ctx.Cookies(constants.RegionCookieKey)

	if region == "" {
		clientAddress := ctx.IP()
		infiniteTime := time.Date(9999, 0, 1, 0, 0, 0, 0, time.UTC)

		netAddress, err := netip.ParseAddr(clientAddress)

		if err != nil {
			return createDefaultResponse(ctx, err)
		}

		geoIpLookup, err := db.GeoIpDb.Country(netAddress)

		if err != nil {
			return createDefaultResponse(ctx, err)
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

	return models.Success(ctx, region)
}
