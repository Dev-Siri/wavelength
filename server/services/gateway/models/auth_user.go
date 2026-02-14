package models

import "github.com/golang-jwt/jwt/v5"

type AuthUser struct {
	UserID      string `json:"userId"`
	DisplayName string `json:"displayName"`
	Email       string `json:"email"`
	PictureURL  string `json:"pictureUrl"`
}

func ClaimsToAuthUser(claims jwt.MapClaims) AuthUser {
	userID := claims["userId"].(string)
	email := claims["email"].(string)
	displayName := claims["displayName"].(string)
	pictureURL := claims["pictureUrl"].(string)

	return AuthUser{
		UserID:      userID,
		Email:       email,
		DisplayName: displayName,
		PictureURL:  pictureURL,
	}
}
