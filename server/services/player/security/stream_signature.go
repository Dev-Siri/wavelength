package security

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"github.com/Dev-Siri/wavelength/server/services/player/types"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/jaevor/go-nanoid"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"
)

const (
	signatureExpirationDuration = time.Hour * 6
	tokenLength                 = 30
	tokenAlphabet               = "0123456789"
)

type TokenClientDetails struct {
	// Whether Hi-Fi stream is available.
	IsHifi bool `json:"isHifi"`
	// Whether lossless stream is available.
	IsLossless *types.LosslessBitType `json:"isLossless"`
	// Client's preferred quality to serve audio.
	PreferredQuality types.PreferredQuality `json:"preferredQuality"`
	Expiration       int64                  `json:"exp"`
	// Ensures that the token cannot be copied onto other devices that don't
	// match the original requesters IP since that is not expected behavior from
	// Wavelength's actual client-side applications.
	IP string `json:"ip"`
	// Ensures that the token is only valid for one particular video stream,
	// to prevent abuse of one token for multiple streams within the expiration period.
	VideoID string `json:"videoId"`
	// Used to query non-adaptive streams.
	ISRC string `json:"isrc"`
	// Email of the user issuing a token creation.
	Email string `json:"email"`
}

func GenerateRedisToken(
	ctx context.Context, clientIP, videoID, isrc, email string,
	preferredQuality types.PreferredQuality, isHifi bool, isLossless *types.LosslessBitType,
) (string, error) {
	generate, err := nanoid.Custom(tokenAlphabet, tokenLength)
	if err != nil {
		return "", err
	}

	token := generate()
	clientDetails := TokenClientDetails{
		Expiration:       time.Now().Add(signatureExpirationDuration).Unix(),
		IP:               clientIP,
		VideoID:          videoID,
		ISRC:             isrc,
		Email:            email,
		IsHifi:           isHifi,
		IsLossless:       isLossless,
		PreferredQuality: preferredQuality,
	}

	logging.Logger.Debug("Created client details.", zap.Any("clientDetails", clientDetails))
	_, err = shared_db.Redis.JSONSet(ctx, token, "$", clientDetails).Result()
	if err != nil {
		return "", err
	}

	return token, nil
}

func FetchIPFromRedisToken(ctx context.Context, token string) (*TokenClientDetails, error) {
	clientDetailsResponse, err := shared_db.Redis.JSONGet(ctx, token, "$").Result()
	if err != nil {
		if err == redis.Nil {
			return nil, errors.New("Token doesn't exist.")
		}
		return nil, err
	}

	var tokenClientDetails []TokenClientDetails
	if err := json.Unmarshal([]byte(clientDetailsResponse), &tokenClientDetails); err != nil {
		return nil, err
	}

	if len(tokenClientDetails) == 0 {
		return nil, errors.New("Token doesn't exist.")
	}

	return &tokenClientDetails[0], nil
}
