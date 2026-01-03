package album_controllers

import (
	"wavelength/services/gateway/api"
	"wavelength/services/gateway/models"

	"github.com/gofiber/fiber/v2"
)

func SearchAlbums(ctx *fiber.Ctx) error {
	query := ctx.Query("q")
	nextPageToken := ctx.Query("nextPageToken")

	if query == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Query (q) is required for searching albums.")
	}

	searchResults, err := api.YouTubeClient.SearchAlbums(query, nextPageToken)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "An error occured while searching for albums: "+err.Error())
	}

	albums := make([]models.Album, 0)

	for _, searchResult := range searchResults.Result {
		album := models.Album{
			AlbumId:     searchResult.AlbumId,
			AlbumType:   "Album",
			Title:       searchResult.Title,
			Thumbnail:   searchResult.Thumbnail,
			Author:      searchResult.Author,
			ReleaseDate: searchResult.ReleaseDate,
			IsExplicit:  searchResult.IsExplicit,
		}

		albums = append(albums, album)
	}

	return models.Success(ctx, albums)
}
