package utils

import "net/url"

func IsValidUrl(testUrl string) bool {
	_, err := url.ParseRequestURI(testUrl)
	return err == nil
}
