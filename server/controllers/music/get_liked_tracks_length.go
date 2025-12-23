package music_controllers

import (
	"context"
	"sync"
	"wavelength/db"
	"wavelength/models"
	"wavelength/utils"

	"github.com/gofiber/fiber/v2"
)

func GetLikedTracksLength(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
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
			`SELECT duration FROM "likes" WHERE email = $1`,
			authUser.Email,
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
			`SELECT COUNT(*) FROM "likes" WHERE email = $1`,
			authUser.Email,
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
				return fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch likes play length: "+err.Error())
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

	// Versatile schema.
	return ctx.JSON(models.Success(models.PlaylistTracksLength{
		SongCount:          songCount,
		SongDurationSecond: totalDurationSeconds,
	}))
}
