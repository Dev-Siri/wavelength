package mediapipe

import (
	"os"
	"os/exec"
	"path/filepath"
)

const (
	FFmpegBitrate256 = "256k"
	FFmpegBitrate320 = "320k"
)

// Reencodes stream from URL to AAC and
// returns the temporary path of the reencoded files.
func ReencodeToAAC(hifiStreamPath string, bitrate string) (string, error) {
	dir, err := os.MkdirTemp("", "")
	if err != nil {
		return "", err
	}

	reencodedFilePath := filepath.Join(dir, "hifi-aac.m4a")
	reencoder := exec.Command(
		"ffmpeg",
		"-i", hifiStreamPath,
		"-vn",
		"-c:a", "aac",
		"-b:a", bitrate,
		"-y",
		reencodedFilePath,
	)

	_ = reencoder.Run()
	return reencodedFilePath, nil
}
