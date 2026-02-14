package session

import (
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/golang-jwt/jwt/v5"
)

func CreateNewJWTToken(userId, email, displayName, pictureURL string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"userId":      userId,
		"email":       email,
		"displayName": displayName,
		"pictureUrl":  pictureURL,
	})

	secret, err := shared_env.GetJwtSecret()
	if err != nil {
		return "", err
	}

	authToken, err := token.SignedString(secret)
	if err != nil {
		return "", err
	}

	return authToken, nil
}
