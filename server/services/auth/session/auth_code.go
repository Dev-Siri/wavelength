package session

import (
	"context"
	"time"

	shared_constants "github.com/Dev-Siri/wavelength/server/shared/constants"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/google/uuid"
)

const authCodeExpiration = time.Minute * 3

func CreateAuthCode(ctx context.Context, token string) (string, error) {
	authCode := uuid.NewString()
	key := shared_constants.AuthCodeKey.K(authCode)

	_, err := shared_db.Redis.Set(ctx, key, token, authCodeExpiration).Result()
	if err != nil {
		return "", err
	}

	return authCode, nil
}

func ConsumeAuthCode(ctx context.Context, code string) (string, error) {
	key := shared_constants.AuthCodeKey.K(code)
	pipe := shared_db.Redis.TxPipeline()

	data := pipe.Get(ctx, key)
	pipe.Del(ctx, key)

	_, err := pipe.Exec(ctx)
	if err != nil {
		return "", err
	}

	return data.Val(), nil
}
