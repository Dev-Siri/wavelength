package artist_controllers

import (
	"strings"
	"wavelength/api"
	"wavelength/logging"
	"wavelength/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetArtistById(ctx *fiber.Ctx) error {
	id := ctx.Params("id")

	response, err := api.YouTubeClient.GetArtistDetails(id)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get artist details from YouTube: "+err.Error())
	}

	restructuredAlbums := make([]models.Album, 0)
	restructuredSinglesAndEps := make([]models.Album, 0)

	for _, artistAlbum := range response.Albums.Contents {
		restructuredAlbum := models.Album{
			AlbumId:     artistAlbum.BrowseId,
			AlbumType:   "Album",
			Title:       artistAlbum.Title,
			Thumbnail:   artistAlbum.Thumbnail,
			Author:      response.Title,
			ReleaseDate: artistAlbum.Subtitle,
			IsExplicit:  artistAlbum.IsExplicit,
		}

		restructuredAlbums = append(restructuredAlbums, restructuredAlbum)
	}

	for _, singleOrEp := range response.SinglesAndEps.Contents {
		subtitleParts := strings.SplitN(singleOrEp.Subtitle, "•", 2)

		if len(subtitleParts) == 0 {
			go logging.Logger.Warn("Skipped singleOrEp because it's subtitle was invalid.", zap.Any("singleOrEp", singleOrEp))
			continue
		}

		albumType := strings.TrimSpace(subtitleParts[0])
		releaseDate := strings.TrimSpace(subtitleParts[1])

		restructuredSinglesAndEp := models.Album{
			AlbumId:     singleOrEp.BrowseId,
			AlbumType:   albumType,
			Title:       singleOrEp.Title,
			Thumbnail:   singleOrEp.Thumbnail,
			Author:      response.Title,
			ReleaseDate: releaseDate,
			IsExplicit:  singleOrEp.IsExplicit,
		}

		restructuredSinglesAndEps = append(restructuredSinglesAndEps, restructuredSinglesAndEp)
	}

	return ctx.JSON(models.Success(models.Artist{
		Title:           response.Title,
		Description:     response.Description,
		SubscriberCount: response.SubscriberCount,
		TopSongs:        response.TopSongs.Contents,
		Albums:          restructuredAlbums,
		SinglesAndEps:   restructuredSinglesAndEps,
	}))
}
