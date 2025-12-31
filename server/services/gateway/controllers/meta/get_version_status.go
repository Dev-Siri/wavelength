package meta_controllers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"wavelength/services/gateway/constants"
	"wavelength/services/gateway/models"

	"github.com/gofiber/fiber/v2"
)

func GetVersionStatus(ctx *fiber.Ctx) error {
	githubTagUrl := fmt.Sprintf("%s/repos/%s/%s/releases/latest", constants.GithubApiUrl, constants.GithubRepoOwner, constants.GithubRepoName)
	response, err := http.DefaultClient.Get(githubTagUrl)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get version tag from GitHub: "+err.Error())
	}

	var requiredResponse models.GithubRequiredResponse

	if err := json.NewDecoder(response.Body).Decode(&requiredResponse); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to parse response from GitHub: "+err.Error())
	}

	if requiredResponse.TagName == "" {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get version status from GitHub.")
	}

	return ctx.JSON(models.Success(models.VersionStatus{
		LatestVersion: requiredResponse.TagName[1:],
	}))
}
