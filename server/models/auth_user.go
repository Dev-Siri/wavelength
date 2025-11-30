package models

type AuthUser struct {
	Id          string `json:"id"`
	DisplayName string `json:"displayName"`
	Email       string `json:"email"`
	PhotoUrl    string `json:"photoUrl"`
}
