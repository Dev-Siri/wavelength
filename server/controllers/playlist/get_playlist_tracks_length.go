package playlist_controllers

import (
	"context"
	"log"
	"sync"
	"wavelength/db"
	"wavelength/models"
	"wavelength/models/responses"
	"wavelength/utils"

	"github.com/gofiber/fiber/v2"
)

func GetPlaylistTracksLength(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")

	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
	}

	durationsChan := make(chan []string, 1)
	countChan := make(chan int, 1)
	errChan := make(chan error, 2)

	var wg sync.WaitGroup
	wg.Add(2)

	go func() {
		defer wg.Done()

		rows, err := db.Database.QueryContext(
			context.Background(),
			`SELECT duration FROM playlist_tracks WHERE playlist_id = $1`,
			playlistId,
		)

		if err != nil {
			errChan <- err
			return
		}

		defer rows.Close()

		var durations []string

		for rows.Next() {
			var duration string
			if err := rows.Scan(&duration); err != nil {
				errChan <- err
				return
			}
			durations = append(durations, duration)
		}

		durationsChan <- durations
	}()

	go func() {
		defer wg.Done()
		var songCount int

		if err := db.Database.QueryRowContext(
			context.Background(),
			`SELECT COUNT(*) FROM playlist_tracks WHERE playlist_id = $1`,
			playlistId,
		).Scan(&songCount); err != nil {
			errChan <- err
			return
		}

		countChan <- songCount
	}()

	go func() {
		wg.Wait()
		close(durationsChan)
		close(countChan)
		close(errChan)
	}()

	var songCount int
	durations := []string{} // Empty slice.

	receivedDurations := false
	receivedCount := false

	for {
		select {
		case d, ok := <-durationsChan:
			if ok {
				durations = d
			}
			receivedDurations = true
		case c, ok := <-countChan:
			if ok {
				songCount = c
			}
			receivedCount = true
		case err, ok := <-errChan:
			if ok {
				log.Println(err)
				return fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch playlist play length with ID: "+playlistId)
			}
		}

		if receivedDurations && receivedCount {
			break
		}
	}

	// Sum durations in seconds
	totalDurationSeconds := 0

	for _, duration := range durations {
		totalDurationSeconds += utils.ParseDurationToSeconds(duration)
	}

	return ctx.JSON(responses.Success[models.PlaylistTracksLength]{
		Success: true,
		Data: models.PlaylistTracksLength{
			SongCount:          songCount,
			SongDurationSecond: totalDurationSeconds,
		},
	})
}
