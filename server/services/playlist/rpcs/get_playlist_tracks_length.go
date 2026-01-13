package playlist_rpcs

import (
	"context"
	"sync"
	"wavelength/proto/commonpb"
	"wavelength/proto/playlistpb"
	shared_db "wavelength/shared/db"
	"wavelength/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (p *PlaylistService) GetPlaylistTracksLength(
	ctx context.Context,
	request *playlistpb.PlaylistTracksLengthRequest,
) (*playlistpb.PlaylistTracksLengthResponse, error) {
	durationsChan := make(chan []int64, 1)
	countChan := make(chan int, 1)
	errChan := make(chan error, 2)

	var wg sync.WaitGroup
	wg.Add(2)

	go func() {
		defer wg.Done()

		rows, err := shared_db.Database.QueryContext(
			context.Background(),
			`SELECT duration FROM playlist_tracks WHERE playlist_id = $1`,
			request.PlaylistId,
		)

		if err != nil {
			errChan <- err
			return
		}

		defer rows.Close()

		var durations []int64

		for rows.Next() {
			var duration int64
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

		if err := shared_db.Database.QueryRowContext(
			context.Background(),
			`SELECT COUNT(*) FROM playlist_tracks WHERE playlist_id = $1`,
			request.PlaylistId,
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
	durations := []int64{}

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
				logging.Logger.Error("Fetch for playlist tracks length failed.", zap.Error(err))
				return nil, status.Error(codes.Internal, "Fetch for playlist tracks length failed.")
			}
		}

		if receivedDurations && receivedCount {
			break
		}
	}

	// Sum durations in seconds
	totalDurationSeconds := int64(0)
	for _, duration := range durations {
		totalDurationSeconds += duration
	}

	return &playlistpb.PlaylistTracksLengthResponse{
		PlaylistTracksLength: &commonpb.TracksLength{
			SongCount:          uint64(songCount),
			SongDurationSecond: uint64(totalDurationSeconds),
		},
	}, nil
}
