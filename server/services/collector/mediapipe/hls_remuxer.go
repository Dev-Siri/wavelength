package mediapipe

import (
	"context"
	"fmt"
	"os"
	"os/exec"
)

func RemuxToHLS(ctx context.Context, extractedURL string) (string, error) {
	dir, err := os.MkdirTemp("", "hls-*")
	if err != nil {
		return "", err
	}

	remuxer := exec.CommandContext(ctx,
		"ffmpeg",
		"-i", extractedURL,
		"-vn",
		"-c:a", "copy",
		"-map", "0:a",
		"-f", "hls",
		"-hls_time", "6",
		"-hls_list_size", "0",
		"-hls_segment_type", "fmp4",
		"-hls_segment_filename", dir+"/seg%d.m4s",
		"-strict", "-2",
		dir+"/index.m3u8",
	)

	out, err := remuxer.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("ffmpeg failed: %s", string(out))
	}

	return dir, nil
}
