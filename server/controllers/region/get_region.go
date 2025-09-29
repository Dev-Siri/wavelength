package region_controllers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
	"wavelength/constants"
	"wavelength/logging"
	"wavelength/models/responses"

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

	return ctx.JSON(
		&responses.Success[string]{
			Success: true,
			Data:    constants.DefaultRegion,
		},
	)
}

func GetRegion(ctx *fiber.Ctx) error {
	region := ctx.Cookies(constants.RegionCookieKey)

	if region == "" {
		clientAddress := ctx.IP()
		infiniteTime := time.Date(9999, 0, 1, 0, 0, 0, 0, time.UTC)

		fmt.Printf("%v", clientAddress)

		geoIpRequestUrl := fmt.Sprintf("%s/geoip/%s", constants.GeoIp2SearchApiUrl, clientAddress)
		geoIpResponse, err := http.Get(geoIpRequestUrl)

		if err != nil {
			return createDefaultResponse(ctx, err)
		}

		var geoIpInfo responses.GeoIpResponse

		if err := json.NewDecoder(geoIpResponse.Body).Decode(&geoIpInfo); err != nil {
			return createDefaultResponse(ctx, err)
		}

		fmt.Printf("%v", geoIpInfo)

		if !geoIpInfo.Success || geoIpInfo.Data.Country == "" {
			return createDefaultResponse(ctx, nil)
		}

		region = geoIpInfo.Data.Country

		ctx.Cookie(&fiber.Cookie{
			Name:     constants.RegionCookieKey,
			Value:    region,
			HTTPOnly: false,
			Secure:   false,
			Expires:  infiniteTime,
		})
	}

	return ctx.JSON(
		&responses.Success[string]{
			Success: true,
			Data:    region,
		},
	)
}
