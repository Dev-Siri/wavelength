package mediapipe

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/Dev-Siri/wavelength/server/shared/tidal"
)

func DownloadHighResAudio(manifestResponse *tidal.TrackResponse) (string, error) {
	dir, err := os.MkdirTemp("", "")
	if err != nil {
		return "", err
	}

	decoded, err := decodeBase64Flexible(manifestResponse.Manifest)
	if err != nil {
		return "", err
	}

	var fetchablePath string

	if manifestResponse.ManifestMimeType == "application/dash+xml" {
		fetchablePath, err = getManifestFilePath(dir, decoded)
	} else {
		fetchablePath, err = getStreamURLFromDecodedManifest(decoded)
	}

	outPath := filepath.Join(dir, "input_audio.flac")
	remuxer := exec.Command(
		"ffmpeg",
		"-protocol_whitelist", "file,https,tcp,tls",
		"-i", fetchablePath,
		"-c", "copy",
		outPath,
	)

	logging.Logger.Debug("Beginning file download.")
	out, err := remuxer.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("ffmpeg failed: %s", string(out))
	}

	logging.Logger.Debug("File downloaded.")
	return outPath, nil
}

func getManifestFilePath(dir string, manifestContent []byte) (string, error) {
	manifestPath := filepath.Join(dir, "input_manifest.mpd")
	if err := os.WriteFile(manifestPath, manifestContent, os.ModePerm); err != nil {
		return "", err
	}

	return manifestPath, nil
}

func getStreamURLFromDecodedManifest(manifestContent []byte) (string, error) {
	type jsonManifest struct {
		URLs []string `json:"urls"`
	}

	var manifestInfo jsonManifest

	if err := json.Unmarshal(manifestContent, &manifestInfo); err != nil {
		return "", err
	}

	return manifestInfo.URLs[0], nil
}

func decodeBase64Flexible(input string) ([]byte, error) {
	input = strings.TrimSpace(input)

	if data, err := base64.StdEncoding.DecodeString(input); err == nil {
		return data, nil
	}

	if data, err := base64.URLEncoding.DecodeString(input); err == nil {
		return data, nil
	}

	if data, err := base64.RawStdEncoding.DecodeString(input); err == nil {
		return data, nil
	}

	if data, err := base64.RawURLEncoding.DecodeString(input); err == nil {
		return data, nil
	}

	return nil, nil
}
