package session

import (
	"context"
	"time"

	shared_constants "github.com/Dev-Siri/wavelength/server/shared/constants"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/google/uuid"
)

const oAuthSessionExpiration = time.Minute * 5

// Create a new OAuth session in Redis, and return the session's ID.
// Each session lasts for 5 minutes before eviction.
func CreateOAuthSession(ctx context.Context, data string) (string, error) {
	oauthSessionID := uuid.NewString()
	key := shared_constants.OAuthSessionKey.K(oauthSessionID)

	_, err := shared_db.Redis.Set(ctx, key, data, oAuthSessionExpiration).Result()
	if err != nil {
		return "", err
	}

	return oauthSessionID, nil
}

// Read the OAuth session's state data stored in Redis. One-time use.
// This method automatically cleans up the state as well immediately after read.
func ConsumeOAuthSessionData(ctx context.Context, oauthSessionID string) (string, error) {
	key := shared_constants.OAuthSessionKey.K(oauthSessionID)
	pipe := shared_db.Redis.TxPipeline()

	data := pipe.Get(ctx, key)
	pipe.Del(ctx, key)

	_, err := pipe.Exec(ctx)
	if err != nil {
		return "", err
	}

	return data.Val(), nil
}
