package region_controllers

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/Dev-Siri/wavelength/server/services/gateway/constants"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

const regionCookieKey = "region"
const defaultRegion = "US"

type lookupResponse struct {
	CountryCode string `json:"countryCode"`
}

func GetRegion(ctx *fiber.Ctx) error {
	region := ctx.Cookies(regionCookieKey)

	if region == "" {
		clientAddress := ctx.IP()
		infiniteTime := time.Date(9999, 0, 1, 0, 0, 0, 0, time.UTC)

		countryCode, err := lookupCountryCode(clientAddress)

		if err != nil {
			return createDefaultResponse(ctx, err)
		}

		region = countryCode

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

func lookupCountryCode(clientAddress string) (string, error) {
	lookupURL := constants.IpApiUrl + "/json/" + clientAddress
	response, err := http.DefaultClient.Get(lookupURL)
	if err != nil {
		return "", err
	}

	defer response.Body.Close()

	var lookup lookupResponse
	if err := json.NewDecoder(response.Body).Decode(&lookup); err != nil {
		return "", err
	}

	return lookup.CountryCode, nil
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
