package models

import "github.com/golang-jwt/jwt/v5"

type AuthUser struct {
	Id          string `json:"id"`
	DisplayName string `json:"displayName"`
	Email       string `json:"email"`
	PhotoUrl    string `json:"photoUrl"`
}

func ClaimsToAuthUser(claims jwt.MapClaims) AuthUser {
	id := claims["id"].(string)
	email := claims["email"].(string)
	displayName := claims["displayName"].(string)
	photoUrl := claims["photoUrl"].(string)

	return AuthUser{
		Id:          id,
		Email:       email,
		DisplayName: displayName,
		PhotoUrl:    photoUrl,
	}
}
