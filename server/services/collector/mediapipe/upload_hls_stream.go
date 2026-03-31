package mediapipe

import (
	"os"
	"path/filepath"

	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"go.uber.org/zap"
)

func UploadHlsStream(id, dir, bucketName string) error {
	files, err := os.ReadDir(dir)
	if err != nil {
		logging.Logger.Error("Stream upload to GCS failed.", zap.Error(err))
		return err
	}

	for _, f := range files {
		path := filepath.Join(dir, f.Name())

		file, err := os.Open(path)
		if err != nil {
			continue
		}

		defer file.Close()

		if err := shared_db.UploadStream(id, bucketName, f.Name(), file); err != nil {
			logging.Logger.Error("Part upload to GCS failed.", zap.Error(err), zap.String("part", f.Name()))
		}
	}

	return nil
}
