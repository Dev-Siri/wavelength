package utils

import (
	"net/mail"
	"net/url"
)

// https://stackoverflow.com/a/66624104/18646049
func IsValidEmail(email string) bool {
	_, err := mail.ParseAddress(email)
	return err == nil
}

func IsValidUrl(testUrl string) bool {
	_, err := url.ParseRequestURI(testUrl)
	return err == nil
}
