package region_controllers

import (
	"encoding/json"
	"io"
	"net/http"
	"time"

	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

const (
	regionCookieKey = "region"
	defaultRegion   = "US"
	ipApiURL        = "https://ip-api.com/json/"
)

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

	return shared_models.Success(ctx, region)
}

func lookupCountryCode(clientAddress string) (string, error) {
	lookupURL := ipApiURL + clientAddress + "?fields=countryCode"
	response, err := http.DefaultClient.Get(lookupURL)
	if err != nil {
		return "", err
	}

	defer response.Body.Close()

	bodyBytes, err := io.ReadAll(response.Body)
	if err != nil {
		return "", err
	}

	logging.Logger.Debug("IPAPI response.", zap.String("status", response.Status), zap.String("response", string(bodyBytes)))

	var lookup lookupResponse
	if err := json.Unmarshal(bodyBytes, &lookup); err != nil {
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

	return shared_models.Success(ctx, defaultRegion)
}
