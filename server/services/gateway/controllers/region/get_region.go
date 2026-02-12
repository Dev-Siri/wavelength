package region_controllers

import (
	"net/netip"
	"time"

	"github.com/Dev-Siri/wavelength/server/services/gateway/db"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

const regionCookieKey = "region"
const defaultRegion = "US"

func GetRegion(ctx *fiber.Ctx) error {
	region := ctx.Cookies(regionCookieKey)

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
			Name:     regionCookieKey,
			Value:    region,
			HTTPOnly: false,
			Secure:   false,
			Expires:  infiniteTime,
		})
	}

	return models.Success(ctx, region)
}

func createDefaultResponse(ctx *fiber.Ctx, err error) error {
	infiniteTime := time.Date(9999, 0, 1, 0, 0, 0, 0, time.UTC)

	logging.Logger.Error("Failed to get region.", zap.Error(err))

	ctx.Cookie(&fiber.Cookie{
		Name:     regionCookieKey,
		Value:    defaultRegion,
		HTTPOnly: false,
		Secure:   false,
		Expires:  infiniteTime,
	})

	return models.Success(ctx, defaultRegion)
}
