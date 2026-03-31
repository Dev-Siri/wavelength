package meta_controllers

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

const (
	githubRepoOwner = "Dev-Siri"
	githubRepoName  = "wavelength"
	githubApiUrl    = "https://api.github.com"
)

func GetVersionStatus(ctx *fiber.Ctx) error {
	githubTagUrl := fmt.Sprintf("%s/repos/%s/%s/releases/latest", githubApiUrl, githubRepoOwner, githubRepoName)
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

	return shared_models.Success(ctx, models.VersionStatus{
		LatestVersion: requiredResponse.TagName[1:],
	})
}
