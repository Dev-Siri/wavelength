package mediapipe

import (
	"context"
	"errors"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"go.uber.org/zap"
)

const (
	FFmpegBitrate256        = "256k"
	FFmpegBitrate320        = "320k"
	validityThreshold int64 = 500
)

// Reencodes stream from URL to AAC and
// returns the temporary path of the reencoded files.
func ReencodeToAAC(ctx context.Context, hifiStreamPath, bitrate string) (string, error) {
	dir, err := os.MkdirTemp("", "")
	if err != nil {
		return "", err
	}

	reencodedFilePath := filepath.Join(dir, "hifi-aac.m4a")
	reencoder := exec.CommandContext(ctx,
		"ffmpeg",
		"-i", hifiStreamPath,
		"-vn",
		"-c:a", "aac",
		"-b:a", bitrate,
		"-y",
		reencodedFilePath,
	)

	// ffmpeg often returns non-0 exit codes for metadata errors even if the file was correctly reencoded.
	// so it's unreliable to trust reencoder.Run()'s errors. The extra check's ensure validity to some extent.
	// however to ensure that it's correctly debuggable, it's printed as a warning if err != nil.
	err = reencoder.Run()

	file, statErr := os.Stat(reencodedFilePath)
	if statErr != nil {
		return "", errors.New("ffmpeg failed because no output was found.")
	}

	if file.Size() < validityThreshold {
		return "", errors.New("ffmpeg failed because output (size) is malformed.")
	}

	if err != nil {
		logging.Logger.Warn("reencoder.Run() returned a non-zero exit-code.", zap.Error(err))
	}

	return reencodedFilePath, nil
}
