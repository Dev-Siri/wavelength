package meta_controllers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"wavelength/services/gateway/constants"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetVersionStatus(ctx *fiber.Ctx) error {
	githubTagUrl := fmt.Sprintf("%s/repos/%s/%s/releases/latest", constants.GithubApiUrl, constants.GithubRepoOwner, constants.GithubRepoName)
	response, err := http.DefaultClient.Get(githubTagUrl)

	if err != nil {
		logging.Logger.Error("Failed to get version tag from GitHub.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get version tag from GitHub.")
	}

	var requiredResponse models.GithubRequiredResponse

	if err := json.NewDecoder(response.Body).Decode(&requiredResponse); err != nil {
		logging.Logger.Error("Failed to parse response from GitHub.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to parse response from GitHub.")
	}

	if requiredResponse.TagName == "" {
		logging.Logger.Error("Failed to get version status from GitHub.")
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get version status from GitHub.")
	}

	return models.Success(ctx, models.VersionStatus{
		LatestVersion: requiredResponse.TagName[1:],
	})
}
