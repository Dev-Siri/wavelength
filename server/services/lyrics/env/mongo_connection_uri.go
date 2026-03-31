package env

import (
	"errors"
	"os"
)

func GetMongoConnectionURI() (string, error) {
	mongoDbConnectionURI := os.Getenv("MONGODB_URI")
	if mongoDbConnectionURI == "" {
		return "", errors.New("No MONGODB_URI set.")
	}

	return mongoDbConnectionURI, nil
}
