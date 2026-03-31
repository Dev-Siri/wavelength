package mediapipe

import (
	"context"
	"io"
	"os"

	"github.com/Dev-Siri/wavelength/server/services/collector/env"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/lrstanley/go-ytdlp"
)

const (
	streamFormat    = "bestaudio[ext=webm]/bestaudio[ext=m4a]/bestaudio/best"
	youtubeWatchURL = "https://www.youtube.com/watch?v="
)

func FetchYouTubeURL(ctx context.Context, videoID string) ([]*ytdlp.ExtractedInfo, error) {
	dl := ytdlp.New().
		Format(streamFormat).
		PrintJSON().
		NoPart().
		NoProgress().
		Quiet()

	ytDlpCookiesPath := env.GetYtDlpCookiesPath()
	if ytDlpCookiesPath != "" {
		tmpPath, err := copyCookiesToTmp(ytDlpCookiesPath)
		if err == nil {
			dl = dl.ExtractorArgs("youtube:player_client=web").
				Cookies(tmpPath)
		}
	} else {
		logging.Logger.Debug("No YouTube cookies environment set.")
		dl = dl.ExtractorArgs("youtube:player_client=android")
	}

	result, err := dl.Run(ctx, youtubeWatchURL+videoID)
	if err != nil {
		return nil, err
	}

	return result.GetExtractedInfo()
}

func copyCookiesToTmp(src string) (string, error) {
	cookies := "/tmp/ytdlp-cookies.txt"

	in, err := os.Open(src)
	if err != nil {
		return "", err
	}
	defer in.Close()

	out, err := os.Create(cookies)
	if err != nil {
		return "", err
	}
	defer out.Close()

	_, err = io.Copy(out, in)
	if err != nil {
		return "", err
	}

	return cookies, nil
}
