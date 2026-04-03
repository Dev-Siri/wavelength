package shared_db

import (
	"context"
	"io"
	"os"
	"strings"
	"time"

	"cloud.google.com/go/storage"
)

const (
	AdaptiveStreamsBucketName = "ytm-streamable-adaptive"
	BaseHifiStreamsBucketName = "spotify-streamable-256"
	TopHifiStreamsBucketName  = "spotify-streamable-320"
	LosslessStreamBucketName  = "universal-lossless"
	playlistExpiration        = time.Hour * 6
	streamChunkExpiration     = time.Minute * 5
)

var Store *storage.Client

var clientEmail = os.Getenv("GCS_SA_EMAIL")
var privateKey = []byte(os.Getenv("GCS_PRIVATE_KEY"))

func InitObjectStorage() error {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*8)
	defer cancel()

	client, err := storage.NewClient(ctx)
	if err != nil {
		return err
	}

	Store = client
	return nil
}

func getObjectName(isrc, part string) string {
	return isrc + "/" + part
}

func UploadStream(ctx context.Context, id, bucketName, streamPartName string, r io.Reader) error {
	objectName := getObjectName(id, streamPartName)

	w := Store.
		Bucket(bucketName).
		Object(objectName).
		NewWriter(ctx)

	_, err := io.Copy(w, r)
	if err != nil {
		w.Close()
		return err
	}

	return w.Close()
}

func generateStreamURL(isrc, bucketName, streamPartName string) (string, error) {
	objectName := getObjectName(isrc, streamPartName)

	var expiration time.Time
	if strings.HasPrefix(streamPartName, ".m3u8") {
		expiration = time.Now().Add(playlistExpiration)
	} else {
		expiration = time.Now().Add(streamChunkExpiration)
	}

	return storage.
		SignedURL(bucketName, objectName, &storage.SignedURLOptions{
			Method:         "GET",
			Expires:        expiration,
			GoogleAccessID: clientEmail,
			PrivateKey:     privateKey,
		})
}

func GenerateAdaptiveURL(videoID, streamPartName string) (string, error) {
	return generateStreamURL(videoID, AdaptiveStreamsBucketName, streamPartName)
}

func GenerateBaseHifiURL(isrc, streamPartName string) (string, error) {
	return generateStreamURL(isrc, BaseHifiStreamsBucketName, streamPartName)
}

func GenerateTopHifiURL(isrc, streamPartName string) (string, error) {
	return generateStreamURL(isrc, TopHifiStreamsBucketName, streamPartName)
}

func GenerateLosslessURL(isrc, streamPartName string) (string, error) {
	return generateStreamURL(isrc, LosslessStreamBucketName, streamPartName)
}
