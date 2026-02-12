package shared_db

import (
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/redis/go-redis/v9"
)

var Redis *redis.Client

func InitRedis() error {
	redisUrl, err := shared_env.GetRedisURL()
	if err != nil {
		return err
	}

	opt, err := redis.ParseURL(redisUrl)
	if err != nil {
		return err
	}

	client := redis.NewClient(opt)
	Redis = client

	return nil
}
